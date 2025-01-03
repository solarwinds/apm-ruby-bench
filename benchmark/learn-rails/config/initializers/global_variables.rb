
meter = OpenTelemetry.meter_provider.meter("benchmark-meter")
Rails.application.config.latency_histogram = meter.create_histogram(ENV['CONTROLLER_METRICS_NAME'], unit: 'smidgen', description: 'a small amount of something')
