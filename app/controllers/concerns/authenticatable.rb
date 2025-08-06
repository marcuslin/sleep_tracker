module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def authenticate_user!
    @current_user = find_current_user

    render_unauthorized unless @current_user
  end

  private

  def find_current_user
    token = extract_token_from_header
    return nil unless token

    decoded_token = Auth::JwtService.decode(token)
    return nil unless decoded_token

    User.find_by(id: decoded_token[:user_id])
  end

  def extract_token_from_header
    auth_header = request.headers["Authorization"]
    return nil unless auth_header

    auth_header.split(" ").last
  end

  def render_unauthorized
    render json: {
      error: {
        message: "Access denied"
      }
    }, status: :unauthorized
  end

  def current_user
    @current_user
  end
end
