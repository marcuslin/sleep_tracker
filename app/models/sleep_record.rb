class SleepRecord < ApplicationRecord
  belongs_to :user

  enum :status, { sleeping: 0, awake: 1 }

  scope :sleeping, -> { where(status: :sleeping) }
end
