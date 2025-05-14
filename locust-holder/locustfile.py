from os import environ
import time
from typing import Iterable
from locust import HttpUser, task, between, events

from opentelemetry import metrics
from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import (
    OTLPMetricExporter,
)
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import (
    ConsoleMetricExporter,
    PeriodicExportingMetricReader
)

service_name = environ.get("SERVICE_NAME", "apm-ruby-benchmark")
resource = Resource.create(
    attributes={
        "service.name": service_name,
        "sw.data.module": "apm",
    }
)

api_token = environ.get("API_TOKEN")
endpoint = environ.get("BENCHMARK_ENDPOINT", "otel.collector.na-01.st-ssp.solarwinds.com:443")
exporter =  OTLPMetricExporter(
    endpoint=endpoint,
    insecure=False,
    headers={
        "authorization": f"Bearer {api_token}"
    }
)

export_interval = environ.get("BENCHMARK_EXPORT_INTERVAL", "5000")
reader = PeriodicExportingMetricReader(
    exporter,
    export_interval_millis=int(export_interval),
)

meter_provider = MeterProvider(
    resource=resource,
    metric_readers=[reader],
)

metrics.set_meter_provider(meter_provider)
otel_meter = meter_provider.get_meter("benchmark-always-sample")

metrics_name = environ.get("CUSTOM_METRICS_NAME", 'apm.ruby.benchmark.response.time')
http_response_time = otel_meter.create_histogram(
    name=metrics_name,
    description="measures the duration of the inbound HTTP request",
    unit="ms")

locust_wait_time_l = int(environ.get("LOCUST_WAIT_TIME_LOW", "10"))
locust_wait_time_h = int(environ.get("LOCUST_WAIT_TIME_HIGH", "20"))
metrics_attribute_name = environ.get("METRICS_ATTRIBUTE_NAME", "apm-ruby-benchmark-attr")

request = {'6.1.2': {'request_count' : 0, 'request_time' : 0 },
           '7.0.0': {'request_count' : 0, 'request_time' : 0 },
           'uninstrumented': {'request_count' : 0, 'request_time' : 0 }
          }

class WebsiteOneUser(HttpUser):
    wait_time = between(locust_wait_time_l, locust_wait_time_h)
    @task
    def load_test_website_one(self):
        self.client.get("http://swo_ruby_6_1_2:8002/", name="6.1.2")
        self.client.get("http://swo_ruby_7_0_0:8002/", name="7.0.0")
        self.client.get("http://uninstrumented:8002/", name="uninstrumented")

# this will be called three times if there are three get
@events.request.add_listener
def report_response_time(response_time, **kw):
    request_name = kw['name']
    request[request_name]['request_count'] += 1
    request[request_name]['request_time'] += int(response_time)
    avg = int(request[request_name]['request_time'] / request[request_name]['request_count'])
    http_response_time.record(avg, attributes={metrics_attribute_name: request_name})
