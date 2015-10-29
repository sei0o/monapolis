require 'active_record'

class Response < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user

  validates :body, presence: true
  validates :received_mona, presence: true
  validates :user_id, presence: true
  validates :topic_id, presence: true
  validates :city_id, presence: true
end
