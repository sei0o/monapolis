require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/flash'
require 'active_record'
require 'yaml'
require 'erb'
require 'bcrypt'
require 'i18n'
require 'unirest'
require 'octokit'
require_relative 'models/user'
require_relative 'models/city'
require_relative 'models/topic'

I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]
I18n.default_locale = :ja

db_config = YAML.load ERB.new(File.read("database.yml")).result
ActiveRecord::Base.establish_connection db_config["development"]

class Monapolis < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    set :config, YAML.load( ERB.new(File.read("config.yml")).result )
  end

  configure do
    enable :sessions
    register Sinatra::Flash
  end

  helpers do
    def t *args
      I18n.t *args
    end

    def login?
      !!session[:user_name]
    end

    def login_user
      login? ? User.find_by(name: session[:user_name])
             : nil
    end

    def user_only
      unless login?
        flash[:warning] = t "user.request_login"
        redirect "/login"
      end
    end
  end

  before do
    @cities = City.all
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
        flash[:notice] = t "user.request_login"
        redirect "/login"
      else
        flash[:warning] = user.errors.full_messages
        redirect back
      end
    else
      flash[:warning] = user.errors.full_messages
      redirect back
    end
  end

  get "/login" do
    slim :login
  end

  post "/login" do
    user = User.find_by name: params[:name].downcase
    if user
      if user.auth params[:password]
        flash[:success] = t "user.auth_succeeded"
        session[:user_name] = user.name
        redirect "/#{user.name}"
      else
        flash[:warning] = t "user.auth_failed"
        redirect back
      end
    else
      flash[:warning] = t "user.not_found"
      redirect back
    end
  end

  post "/auth_third" do
    case params[:login_with]
    when "github"
      redirect "https://github.com/login/oauth/authorize?client_id=#{settings.config['github_client_id']}"
    end
  end

  get "/github_callback" do
    response = Unirest.post("https://github.com/login/oauth/access_token", headers: {
        "Accept" => "application/json"
      }, parameters: {
        code: params[:code],
        client_id: settings.config["github_client_id"],
        client_secret: settings.config["github_client_secret"]
      }).body

    github = Octokit::Client.new access_token: response["access_token"]
    p github.user

    if user = User.find_by(github_name: github.user.name)
      session[:user_name] = user.name
      flash[:success] = t "user.auth_succeeded"
      redirect "/#{user.name}"
    else
      u = User.new(
        name: github.user.name,
        github_name: github.user.name,
        password: "none",
        password_salt: "none"
      )

      if u.save
        flash[:success] = t "user.auth_succeeded"
        session[:user_name] = u.name
        redirect "/#{u.name}"
      else
        flash[:warning] = t "user.wtf"
        session[:user_name] = u.name
        redirect "/register"
      end
    end
  end

  get "/settings" do
    user_only

    slim :settings
  end

  post "/settings" do
    user_only

    user = login_user

    user.name = params[:name].downcase

    if user.save
      session[:user_name] = user.name
      flash[:success] = t "user.settings_succeeded"
      redirect "/#{user.name}"
    else
      flash[:warning] = t "user.wtf"
      redirect back
    end
  end

  get "/c" do
    @cities = City.all
    slim :cities
  end

  get "/c/new" do
    user_only

    slim :new_city
  end

  post "/c/new" do
    user_only

    city = City.new name: params[:name], code: params[:code].downcase

    if city.save
      flash[:success] = t "city.create_succeeded"
      redirect "/c/#{city.code}"
    else
      flash[:warning] = city.errors.full_messages
      redirect back
    end
  end

  get "/c/:code/new" do |code|
    @city = City.find_by code: code.downcase
    slim :new_topic
  end

  post "/c/:code/new" do |code|
    city = City.find_by code: code.downcase
    topic = Topic.new title: params[:title], id: city.topics.size
    topic.city = city

    if topic.save
      flash[:success] = t "topic.create_succeeded"
      redirect "/c/#{city.code}/#{topic.id}"
    else
      flash[:warning] = topic.errors.full_messages
      redirect back
    end
  end

  get "/c/:code/:id" do |code, topic_id|
    @city = City.find_by code: code.downcase
    @topic = Topic.where id: topic_id, city_id: @city.id
    slim :topic
  end

  get "/c/*" do |code|
    @city = City.find_by code: code.downcase
    slim :city
  end

  get "/*" do |name|
    @user = User.find_by name: name.downcase

    unless @user
      flash[:warning] = t "user.not_found"
      redirect back
    end

    slim :user
  end
end
