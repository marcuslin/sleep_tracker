class Api::V1::FollowsController < ApplicationController
  def follow_users
    interaction = Follows::FollowUserInteraction.run(
      user: current_user,
      followee_id: params[:followee_id]
    )

    if interaction.valid?
      render json: {
        success: true,
        data: {
          follow: interaction.result
        }
      }, status: :created
    else
      render json: {
        success: false,
        error: {
          message: interaction.errors.full_messages.join(", ")
        }
      }, status: :unprocessable_entity
    end
  end

  def unfollow_users
    interaction = Follows::UnfollowUserInteraction.run(
      user: current_user,
      followee_id: params[:followee_id]
    )

    if interaction.valid?
      render json: {
        success: true,
        data: {
          message: I18n.t("follows.successfully_unfollow"),
          unfollow: interaction.result
        }
      }, status: :ok
    else
      render json: {
        success: false,
        error: {
          message: interaction.errors.full_messages.join(", ")
        }
      }, status: :unprocessable_entity
    end
  end
end
