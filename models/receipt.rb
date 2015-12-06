require 'active_record'

class Receipt < ActiveRecord::Base
  belongs_to :response, class_name: "Response", foreign_key: "receiver_response_id"
  belongs_to :sender, class_name: "User", foreign_key: "sender_user_id"
  belongs_to :receiver, class_name: "User", foreign_key: "receiver_user_id"

  enum kind: {
    deposit: 0,
    withdraw: 1,
    tip_response: 10,
    tip_user: 11,
    penalty: 20,
    gift: 21
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :kind, presence: true
  validate :insufficient_balance

  def insufficient_balance
    if sender && self.sender.balance - self.amount < 0
      errors.add(:amount, :insufficient_balance)
    end
  end
end
