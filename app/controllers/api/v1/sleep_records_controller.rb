class Api::V1::SleepRecordsController < ApplicationController
  # TODO
  # add index with cursor-based pagination in order to cover
  # the missing requirement of returning all sleep records
  # while clocking in, considering users may have alot of
  # sleep records returning them all in an API response is not ideal.

  def clock_in
    interaction = SleepRecords::ClockInInteraction.run(user: current_user)

    if interaction.valid?
      render json: {
        success: true,
        data: {
          new_record: interaction.result,
          sleep_records: current_user.sleep_records
                        .order(created_at: :desc)
                        .limit(ENV.fetch("SLEEP_RECORDS_LIMIT", 50).to_i)
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
    interaction = SleepRecords::ClockOutInteraction.run(user: current_user)

    if interaction.valid?
      render json: {
        success: true,
        data: {
          sleep_record: interaction.result
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
