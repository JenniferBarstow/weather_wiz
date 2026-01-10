source "https://rubygems.org"

gem "rails", "~> 8.1.1"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "httparty"
gem "redis", "~> 5.0"
gem 'sassc-rails'
gem "jquery-rails"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "pry"
  gem "rspec-rails"
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem 'rails-controller-testing'
end