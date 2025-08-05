class User < ApplicationRecord
  has_many :sleep_records, dependent: :destroy
  
  # Following relationships
  has_many :follows, foreign_key: :follower_id, dependent: :destroy
  has_many :followees, through: :follows, source: :followee
  
  # Follower relationships  
  has_many :followers_follows, class_name: 'Follow', foreign_key: :followee_id, dependent: :destroy
  has_many :followers, through: :followers_follows, source: :follower
end
