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

  def friends_weekly
    friend_ids = current_user.followees.pluck(:id)
    friends_records = SleepRecord.where(user_id: friend_ids)
                                 .where(created_at: last_week_range)
                                 .where.not(duration: nil)
                                 .includes(:user)

    paginated_records = PaginationService.new(
      friends_records,
      params[:cursor],
      :duration,
      :desc,
      params[:limit]
    ).call

    render json: {
      success: true,
      data: serialize(paginated_records[:records]),
      meta: {
        next_cursor: paginated_records[:next_cursor]
      }
    }
  end

  private

  def last_week_range
    last_week_start = Date.current.beginning_of_week.prev_week
    last_week_end = last_week_start.end_of_week

    last_week_start..last_week_end
  end

  def serialize(sleep_records)
    sleep_records.map { |record| SleepRecordSerializer.serialize(record) }
  end
end
