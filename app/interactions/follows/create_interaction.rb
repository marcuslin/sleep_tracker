class Follows::CreateInteraction < ActiveInteraction::Base
  object :user
  integer :followee_id

  validate :followee_exists
  validate :cannot_follow_self
  validate :duplicate_follow

  def execute
    user.follows.create!(followee: followee)
  end

  private

  def cannot_follow_self
    errors.add(:base, I18n.t("interactions.follows.follow_user.cannot_follow_self")) if user.id == followee_id
  end

  def duplicate_follow
    errors.add(:base, I18n.t("interactions.follows.follow_user.duplicate_follow")) if user.follows.exists?(followee: followee)
  end

  def followee_exists
    errors.add(:base, I18n.t("interactions.follows.follow_user.followee_not_found")) unless followee
  end

  def followee
    @followee ||= User.find_by(id: followee_id)
  end
end
