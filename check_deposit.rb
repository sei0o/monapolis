require 'active_record'
require 'monacoin_client'
require_relative 'models/user'
require_relative 'models/receipt'

db_config = YAML.load ERB.new(File.read("database.yml")).result
ActiveRecord::Base.establish_connection db_config["development"]

class DepositChecker
  def initialize
    @config = YAML.load( ERB.new(File.read("config.yml")).result )
    @wallet = MonacoinRPC.new("http://#{@config["monacoind_user"]}:#{@config["monacoind_password"]}@#{@config["monacoind_host"]}:#{@config["monacoind_port"]}")
  end

  def watch
    Thread.abort_on_exception = true

    t = Thread.new do
      loop do
        check_wallet
        sleep 10
      end
    end
  end

  def check_wallet
    User.all.each do |user|
      if user.wallet_balance > 0
        Receipt.create receiver_user_id: user.id, amount: user.wallet_balance, kind: :deposit

        # 共用addressにmove
        @wallet.move user.wallet_account, @config["shared_wallet"], user.wallet_balance
      end
    end
  end
end
