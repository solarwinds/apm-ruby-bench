require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module OverWriteMetrics
  def record_sampling_metrics
    @metrics[:tracecount].add(rand(1..10))
    @metrics[:samplecount].add(rand(1..10))
    @metrics[:request_count].add(rand(1..10))
    @metrics[:toex_count].add(rand(1..10))
    @metrics[:through_count].add(rand(1..10))
    @metrics[:tt_count].add(rand(1..10))
  end

  # new metrics sdk use periodic table by default
  def on_finish(span)
    SolarWindsAPM.logger.debug { "[#{self.class}/#{__method__}] processor on_finish span: #{span.to_span_data.inspect}" }

    return if non_entry_span(span: span)

    record_request_metrics(span)
    record_sampling_metrics

    SolarWindsAPM.logger.debug { "[#{self.class}/#{__method__}] processor on_finish succeed" }
  rescue StandardError => e
    SolarWindsAPM.logger.info { "[#{self.class}/#{__method__}] error processing span on_finish: #{e.message}" }
  end
end

require 'solarwinds_apm'

SolarWindsAPM::OpenTelemetry::OTLPProcessor.prepend(OverWriteMetrics) if defined? (::SolarWindsAPM::OpenTelemetry)
SecureHeaders::Configuration.default if defined?(SecureHeaders)

module TestApp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
