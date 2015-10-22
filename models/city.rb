require 'active_record'

class City < ActiveRecord::Base
  has_many :topics, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :code, presence: true, uniqueness: true
end
