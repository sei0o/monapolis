require 'sinatra'

class Monapolis < Sinatra::Base
  configure do
    set :server, :puma
  end
end
