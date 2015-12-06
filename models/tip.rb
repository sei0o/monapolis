require 'active_record'
require_relative 'user'
require 'i18n'

class Tip < ActiveRecord::Base
  belongs_to :response
  belongs_to :user

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :user_id, presence: true
  validates :response_id, presence: true
  validate :insufficient_balance

  def insufficient_balance
    if User.find(self.user_id).balance < self.amount
      errors.add(:amount, :insufficient_balance)
    end
  end
end
