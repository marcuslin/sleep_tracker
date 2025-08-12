class SleepRecordSerializer
  def self.serialize(record)
    {
      id: record.id,
      user_id: record.user_id,
      user_name: record.user.name,
      duration: record.duration,
      clock_in_time: record.clock_in_time,
      clock_out_time: record.clock_out_time,
      created_at: record.created_at
    }
  end
end
