class SleepRecords::ClockInInteraction < ActiveInteraction::Base
  object :user

  validate :sleeping_record_exists

  def execute
    user.sleep_records.create!(
      clock_in_time: Time.now,
      status: :sleeping
    )
  end

  private

  def sleeping_record_exists
    if user.sleep_records.sleeping.exists?
      errors.add(:base, I18n.t("interactions.sleep_records.clock_in.already_sleeping"))
    end
  end
end
