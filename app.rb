require 'sinatra'
require 'sinatra/reloader' if development?
require 'active_record'
require 'yaml'
require 'erb'
require 'models/user'

db_config = YAML.load ERB.new(File.read("database.yml")).result
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
