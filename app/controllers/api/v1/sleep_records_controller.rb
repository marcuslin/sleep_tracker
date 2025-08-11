class Api::V1::SleepRecordsController < ApplicationController
  def clock_in
    interaction = SleepRecords::ClockInInteraction.run(user: current_user)

    if interaction.valid?
      render json: {
        success: true,
        data: {
          new_record: interaction.result,
          sleep_records: current_user.sleep_records.order(created_at: :desc)
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

  def clock_out
  end
end
