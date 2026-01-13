require "active_support/core_ext/integer/time"

Rails.application.configure do
  # config.cache_store = :memory_store
  config.cache_store = :redis_cache_store, { url: ENV['REDIS_URL'], expires_in: 30.minutes }

  config.enable_reloading = true
  config.eager_load = false
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = true

  config.active_storage.service = :local
  config.action_mailer.raise_delivery_errors = false

  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.action_controller.raise_on_missing_callback_actions = true

end
