class SleepRecords::ClockOutInteraction < ActiveInteraction::Base
  object :user

  def execute
    return sleep_record unless sleeping_record_exists?

    clock_out_time = Time.current
    duration = calculate_duration(clock_out_time)

    sleep_record.update!(
      clock_out_time: clock_out_time,
      duration: duration
    )

    sleep_record.awake!

    sleep_record
  end

  private

  def sleeping_record_exists?
    unless sleep_record
      errors.add(:base, I18n.t("interactions.sleep_records.clock_out.no_sleeping_record"))
    end

    !sleep_record.nil?
  end

  def calculate_duration(clock_out_time)
    (clock_out_time - sleep_record.clock_in_time) / 1.hour
  end

  def sleep_record
    @sleep_record ||= user.sleep_records.sleeping.first
  end
end
