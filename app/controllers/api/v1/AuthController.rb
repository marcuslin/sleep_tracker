class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_user!

  def login
    user = User.find_by(id: params[:user_id])

    if user
      token = Auth::JwtService.encode(user_id: user.id)

      render json: {
        success: true,
        data: {
          token: token,
          user: { id: user.id, name: user.name }
        }
      }
    else
      render json: {
        success: false,
        error: {
          message: "Access denied"
        }
      }, status: :unauthorized
    end
  end
end
