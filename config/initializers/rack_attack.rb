class Rack::Attack
  throttle('all_api_requests/ip', limit: 300, period: 5.minutes) do |req|
    if req.path.start_with?('/api/')
      req.ip
    end
  end
end

  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |name, start, finish, request_id, payload|
    req = payload[:request]

    Rails.logger.warn "Throttled #{payload[:name]} from IP: #{req.ip} to path: #{req.path}"
  end

Rails.application.config.middleware.use Rack::Attack
