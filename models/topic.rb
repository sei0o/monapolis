require 'active_record'

class Topic < ActiveRecord::Base
  belongs_to :city

  validates :title, presence: true, uniqueness: true
  validates :city_id, presence: true
end
