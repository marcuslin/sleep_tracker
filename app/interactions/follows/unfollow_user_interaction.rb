class Follows::UnfollowUserInteraction < ActiveInteraction::Base
  object :user
  integer :followee_id

  validate :followee_exists
  validate :can_unfollow

  def execute
    user.follows.find_by!(followee: followee).destroy!
  end

  private

  def followee_exists
    errors.add(:followee_id, I18n.t("interactions.follows.unfollow_user.unfollowee_not_found")) unless followee
  end

  def can_unfollow
    errors.add(:followee_id, I18n.t("interactions.follows.unfollow_user.not_following")) unless user.follows.exists?(followee: followee)
  end

  def followee
    @followee ||= User.find_by(id: followee_id)
  end
end
