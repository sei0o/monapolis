require 'active_record'
require 'bcrypt'

class User < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :password, presence: true
  validates :password_salt, presence: true

  def hash_password p 
    self.password_salt = BCrypt::Engine.generate_salt
    self.password = BCrypt::Engine.hash_secret p, self.password_salt
  end

  def validate_password_length p
    if p.size < 10
      errors[:base] << "パスワードが短すぎます"
      return false
    end
    true
  end

end
