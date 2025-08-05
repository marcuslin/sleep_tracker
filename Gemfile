source "https://rubygems.org"

ruby "3.4.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.2"

# Database
gem "pg", "~> 1.1"
gem "makara"

# Web server
gem "puma", ">= 5.0"

# JSON handling
gem "oj"

# Authentication
gem "jwt"

# Caching and background jobs
gem "redis", ">= 4.0"
gem "sidekiq"
gem "sidekiq-cron"

# Security and rate limiting
gem "rack-attack"

# Business logic encapsulation
gem "active_interaction", "~> 5.3"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem "rack-cors"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

group :development, :test do
  # Environment variables
  gem "dotenv"

  # Testing framework
  gem "rspec-rails"

  # Debugging with pry
  gem "pry-rails"
  gem "pry-byebug"
  gem "awesome_print"
end

group :development do
  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Performance monitoring
  gem "bullet"
end

group :test do
  # Test-specific gems
  gem "factory_bot_rails"
  gem "shoulda-matchers"
end
