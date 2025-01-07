## Build/Run the image

```sh
docker build . -t locust_app_holder:latest --no-cache
docker run  -it --rm --name locust_app_holder locust_app_holder
```

## locustfile

Locust doesn’t have a built-in function specifically named report_response_time,
but you can track and report response times using Locust’s event hooks and the request event.
Here’s an example of how you can log response times:

https://docs.locust.io/en/stable/running-without-web-ui.html
locust --headless -u 100 --run-time 60 --host http://0.0.0.0:8002 # default unit is seconds
locust --headless -u 100 --host http://0.0.0.0:8002

On multiple host
https://github.com/locustio/locust/issues/150

## Configurable ENV variable


 ENV                        | Default                                         | Description 
 --------------------------- |----------------------------------------------- |-------------
 SERVICE_NAME               | apm-ruby-benchmark                              | service name that will show up in swo backend
 API_TOKEN                  | N/A                                             | service key from swo backends
 BENCHMARK_ENDPOINT         | otel.collector.na-01.st-ssp.solarwinds.com:443  | destination where the benchmark metrics will be sent
 BENCHMARK_EXPORT_INTERVAL  | 5000                                            | time interval for periodic exporter to send data
 CUSTOM_METRICS_NAME        | apm.ruby.benchmark.response.time                | metrics name for locating the metrics in series on dashboard
 LOCUST_WAIT_TIME_LOW       | 10                                              | locust will have delay time to send request each time, this defines lower end
 LOCUST_WAIT_TIME_HIGH      | 20                                              | this defines higher end
 METRICS_ATTRIBUTE_NAME     | apm-ruby-benchmark-attr                         | for better locating the metrics and aggregation


## Get other docker stats

curl --unix-socket /var/run/docker.sock http://host.docker.internal/containers/174bcbe44471/stats?stream=false

## Checklist

1. all trace should have entry span with `"http.route":"/` (`Name           : GET /` for otlp proto)
