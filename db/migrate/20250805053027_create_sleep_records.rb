class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :clock_in_time, null: false
      t.datetime :clock_out_time
      t.float :duration
      t.integer :status, null: false, default: 0  # enum: sleeping=0, awake=1

      t.timestamps
    end
    
    # Business logic constraint - only one sleeping record per user
    add_index :sleep_records, [:user_id, :status], unique: true, where: "status = 0"
    
    # Performance indexes for common queries
    add_index :sleep_records, [:user_id, :created_at]
    add_index :sleep_records, [:duration, :id], order: { duration: :desc, id: :desc }
    add_index :sleep_records, :created_at
    add_index :sleep_records, [:status, :clock_in_time]
  end
end
