class CreateFollows < ActiveRecord::Migration[8.0]
  def change
    create_table :follows do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :followee, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    # Prevent duplicate follows and enable fast lookups
    add_index :follows, [ :follower_id, :followee_id ], unique: true
  end
end
