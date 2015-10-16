require 'sinatra'
require 'sinatra/reloader' if development?

class Monapolis < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get "/" do
    slim :index
  end

  get "/about" do
    slim :about
  end
end
