require 'sinatra'
require 'sinatra/reloader' if development?
require 'active_record'
require 'yaml'

db_config = YAML.load_file "database.yml"
ActiveRecord::Base.establish_connection db_config["development"]

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
