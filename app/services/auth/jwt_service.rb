module Auth
  class JwtService
    SECRET_KEY = Rails.application.secret_key_base

    def self.encode(payload)
      payload[:exp] = 24.hours.from_now.to_i
      JWT.encode(payload, SECRET_KEY)
    end

    def self.decode(token)
      decoded = JWT.decode(token, SECRET_KEY).first
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::ExpiredSignature, JWT::DecodeError
      nil
    end
  end
end
