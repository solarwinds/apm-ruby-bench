class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :start_stats
  after_action :log_stats

  private

  def start_stats
    @start_time = Time.now
  end

  def log_stats
    return if ENV['EXPORT_CONTROLLER_DURATION'] == 'false'

    end_time = Time.now

    time_taken = end_time - @start_time

    Rails.application.config.latency_histogram.record(time_taken, attributes: {ENV['METRICS_ATTRIBUTE_NAME'] => ENV['AGENT_TYPE'] })

    if ::OpenTelemetry.meter_provider.metric_readers.size == 1
      ::OpenTelemetry.meter_provider.metric_readers.first.pull
    elsif ::OpenTelemetry.meter_provider.metric_readers.size == 2
      ::OpenTelemetry.meter_provider.metric_readers[1].pull
    end
  end
end
