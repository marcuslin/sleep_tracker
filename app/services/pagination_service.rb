class PaginationService
  attr_reader :relation, :cursor, :limit,
              :order_by, :order

  def initialize(relation, cursor, order_by, order, limit)
    @relation = relation
    @cursor = cursor
    @limit = sanitize_limit(limit)
    @order_by = order_by
    @order = order.to_s.downcase.to_sym
  end

  def call
    {
      records: actual_records,
      next_cursor: next_cursor
    }
  end

  private

  def fetch_records
    query = relation.order(order_by => order, id: order)
                    .limit(limit + 1)

    if cursor
      order_value, record_id = decode_cursor

      query = query.where(
        record_query_clause,
        order_value, order_value, record_id
      )
    end

    query
  end

  def encode_cursor(record)
    Base64.strict_encode64("#{formatted_value(record)}|#{record.id}")
  end

  def decode_cursor
    decoded = Base64.strict_decode64(cursor).split("|")
    order_value_str = decoded.first
    record_id = decoded.last

    [ convert(order_value_str), record_id.to_i ]
  rescue StandardError => e
    raise ArgumentError, "Invalid cursor format"
  end

  def formatted_value(record)
    order_value = record.send(order_by)

    case order_value
    when Time, DateTime
      order_value.utc.iso8601
    when Date
      order_value.iso8601
    else
      order_value.to_s
    end
  end

  def convert(order_value)
    case order_by
    when :created_at, :updated_at, :clock_in_time, :clock_out_time
      Time.parse(order_value)
    when :duration
      order_value.to_f
    else
      order_value
    end
  end

  def record_query_clause
    return "(#{order_by} < ?) OR (#{order_by} = ? AND id < ?)" if order == :desc

    "(#{order_by} > ?) OR (#{order_by} = ? AND id > ?)"
  end

  def actual_records
    return records unless records.size > limit

    records.first(limit)
  end

  def next_cursor
    return nil unless records.size > limit

    encode_cursor(records[-2])
  end

  def records
    @records ||= fetch_records
  end

  def sanitize_limit(limit)
    requested_limit = (limit || 20).to_i
    max_limit = ENV.fetch("MAX_PAGE_SIZE", 100).to_i

    [ [ requested_limit, 1 ].max, max_limit ].min
  end
end
