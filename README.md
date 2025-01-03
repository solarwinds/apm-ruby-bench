# apm-ruby-bench

## Running the docker compose

```
docker compose -f docker-compose-apm-ruby-benchmark.yml up
```

Additional configuration for service `locust_app_holder` can check `locust-holder/README.md` 

Replace `env.example` to `.env` and add the required credentials

### Running with local collector

Change the following env:
```yaml
swo_ruby_apm_on:
  ...
  environment:
    ...
    SW_APM_COLLECTOR: ${JAVA_COLLECTOR}

swo_ruby_apm_otlp_on:
  ...
  environment:
    ...
    OTEL_EXPORTER_OTLP_METRICS_ENDPOINT: ${OTEL_EXPORTER_OTLP_METRICS_ENDPOINT_LOCAL}
    OTEL_EXPORTER_OTLP_TRACES_ENDPOINT: ${OTEL_EXPORTER_OTLP_TRACES_ENDPOINT_LOCAL}
```

## Run Locust Testing

It's recommended to run in host machine because you can see the graph

Install Locust
```sh
apt-get update && apt-get install python3-pip python3.12-venv vim

# create python virtual env
python3 -m venv locustenv
# activate virtual env
source locustenv/bin/activate

pip3 install locust
```

Create locustfile.py for host machine
```python
from locust import HttpUser, task, between

class WebsiteOneUser(HttpUser):
    wait_time = between(1, 5)
    @task
    def load_test_website_one(self):
        self.client.get("http://0.0.0.0:8002/", name="with_apm")
        self.client.get("http://0.0.0.0:8004/", name="with_otlp_apm")
        self.client.get("http://0.0.0.0:8003/", name="without_apm")
```

Create locustfile.py for container machine
```python
from locust import HttpUser, task, between

class WebsiteOneUser(HttpUser):
    wait_time = between(1, 5)
    @task
    def load_test_website_one(self):
        self.client.get("http://swo_ruby_apm_benchmark_on-1:8002/", name="with_apm")
        self.client.get("http://swo_ruby_apm_benchmark_otlp_on-1:8002/", name="with_otlp_apm")
        self.client.get("http://swo_ruby_apm_benchmark_off-2:8002/", name="without_apm")
```

Run the locust without web UI
```sh
locust --headless -u 100 --run-time 60 --host http://0.0.0.0:8002 # default unit is seconds
```

Run the locust with web UI
```sh
locust
```

## SolarWinds Docker integration

### Setup:
Connect ec2 to solarwinds: https://documentation.solarwinds.com/en/success_center/observability/content/configure/configure-host.htm

Setup docker monitor: https://documentation.solarwinds.com/en/success_center/observability/content/configure/configure-docker.htm

benchmark dashboard: https://my.na-01.st-ssp.solarwinds.com/205939959869206528/entities/docker-daemons/e-1791561768517537792/overview?duration=3600

Check if the solarwinds service is up:
```
service uamsclient status
```
