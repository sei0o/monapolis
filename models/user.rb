require 'active_record'

class User < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :password, presence: true
  validates :password_salt, presence: true
end
