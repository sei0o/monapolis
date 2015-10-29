require 'active_record'

class Topic < ActiveRecord::Base
  belongs_to :city
  has_many :responses

  validates :title, presence: true, uniqueness: true
  validates :city_id, presence: true
end
