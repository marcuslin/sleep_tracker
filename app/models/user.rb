class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy
  
  # Who this user follows
  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :followees, through: :follows, source: :followee
  
  # Who follows this user
  has_many :followed_by, class_name: 'Follow', foreign_key: :followee_id, dependent: :destroy
  has_many :followers, through: :followed_by, source: :follower
end
