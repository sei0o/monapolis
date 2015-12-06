require 'active_record'

class Response < ActiveRecord::Base
  belongs_to :topic
  belongs_to :user
  has_many :receipts, class_name: "Receipt", foreign_key: "receiver_response_id"

  validates :body, presence: true
  validates :user_id, presence: true
  validates :topic_id, presence: true

  def received_mona
    receipts.inject(0.0) { |sum, receipt| sum + receipt.amount }
  end
end
