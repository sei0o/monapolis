require 'active_record'
require 'bcrypt'

class User < ActiveRecord::Base
  @@config = YAML.load( ERB.new(File.read("config.yml")).result )
  @@wallet = MonacoinRPC.new("http://#{@@config["monacoind_user"]}:#{@@config["monacoind_password"]}@#{@@config["monacoind_host"]}:#{@@config["monacoind_port"]}")

  has_many :responses

  validates :name, presence: true, uniqueness: true
  validates :password, presence: true
  validates :password_salt, presence: true
  validates :wallet_address, presence: true, uniqueness: true

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

  def auth p
    self.password == BCrypt::Engine.hash_secret(p, self.password_salt)
  end

  def wallet_account
    @@config["wallet_address_prefix"] + self.name
  end

  def balance confirmed = 6
    @@wallet.getbalance self.wallet_account, confirmed
  end
end
