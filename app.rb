require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/flash'
require 'active_record'
require 'yaml'
require 'erb'
require 'bcrypt'
require 'i18n'
require_relative 'models/user'

I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]
I18n.default_locale = :ja

db_config = YAML.load ERB.new(File.read("database.yml")).result
ActiveRecord::Base.establish_connection db_config["development"]

class Monapolis < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    enable :sessions
    register Sinatra::Flash
  end

  helpers do
    def t *args
      I18n.t *args
    end
  end

  get "/" do
    slim :index
  end

  get "/about" do
    slim :about
  end

  get "/register" do
    slim :register
  end

  post "/register" do
    user = User.new name: params[:name].downcase

    if user.validate_password_length params[:password]
      user.hash_password params[:password]
      if user.save
        redirect "/#{user.name}"
      else
        flash[:warning] = user.errors.full_messages
        redirect back
      end
    else
      flash[:warning] = user.errors.full_messages
      redirect back
    end
  end
end
