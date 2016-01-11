require 'active_record'
require 'bcrypt'

class User < ActiveRecord::Base
  @@config = YAML.load( ERB.new(File.read("config.yml")).result )
  @@wallet = MonacoinRPC.new("http://#{@@config["monacoind_user"]}:#{@@config["monacoind_password"]}@#{@@config["monacoind_host"]}:#{@@config["monacoind_port"]}")

  has_many :responses
  has_many :receipts_as_sender, class_name: "Receipt", foreign_key: "sender_user_id"
  has_many :receipts_as_receiver, class_name: "Receipt", foreign_key: "receiver_user_id"

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
    @@config["wallet_address_prefix"] + self.id.to_s
  end

  def wallet_balance confirmed = 0
    @@wallet.getbalance self.wallet_account, confirmed
  end

  def balance
    paid = receipts_as_sender.inject(0.0) { |sum, receipt| sum + receipt.amount }
    got = receipts_as_receiver.inject(0.0) { |sum, receipt| sum + receipt.amount }

    got - paid
  end
end
