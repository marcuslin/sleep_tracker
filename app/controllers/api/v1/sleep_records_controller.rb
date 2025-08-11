class Api::V1::SleepRecordsController < ApplicationController
  def index
    pagination_service = PaginationService.new(
      current_user.sleep_records,
      params[:cursor],
      :created_at,
      :desc,
      params[:limit]
    )

    result = pagination_service.call

    render json: {
      success: true,
      data: result[:records],
      meta: {
        next_cursor: result[:next_cursor]
      }
    }
  end

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
