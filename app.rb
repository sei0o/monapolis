require 'sinatra'

class Monapolis < Sinatra::Base
  configure do
    set :server, :puma
  end

  get "/" do
    slim :index
  end
end
