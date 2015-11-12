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
require 'monacoin_client'
require_relative 'models/user'
require_relative 'models/city'
require_relative 'models/topic'
require_relative 'models/response'

I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s]
I18n.default_locale = :ja

db_config = YAML.load ERB.new(File.read("database.yml")).result
ActiveRecord::Base.establish_connection db_config["development"]

class Monapolis < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    set :config, YAML.load( ERB.new(File.read("config.yml")).result )
    set :wallet, MonacoinRPC.new("http://#{config["monacoind_user"]}:#{config["monacoind_password"]}@#{config["monacoind_host"]}:#{config["monacoind_port"]}")
  end

  configure do
    enable :sessions
    register Sinatra::Flash
  end

  helpers do
    include Rack::Utils

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

    def escape_nl2br str
      escape_html(str).gsub(/\r\n|\n|\r/, "<br>")
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
    user = User.new name: params[:name].downcase, wallet_address: settings.wallet.getnewaddress

    if user.validate_password_length params[:password]
      user.hash_password params[:password]
      if user.save
        settings.wallet.setaccount user.wallet_address, user.wallet_account

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
        password_salt: "none",
        wallet_address: settings.wallet.getnewaddress
      )

      if u.save
        settings.wallet.setaccount u.wallet_address, u.wallet_account

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

  get "/deposit" do
    user_only

    slim :deposit
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
    topic = Topic.new title: params[:title]
    topic.city = city

    if topic.save
      flash[:success] = t "topic.create_succeeded"
      redirect "/c/#{city.code}/#{topic.id}"
    else
      flash[:warning] = topic.errors.full_messages
      redirect back
    end
  end

  post "/c/:code/:id/response" do |code, topic_id|
    user_only

    city = City.find_by code: code.downcase
    topic = Topic.find_by id: topic_id

    response = Response.new body: params[:body]
    response.user_id = login_user.id
    response.topic_id = topic.id

    if response.save
      flash[:success] = t "response.post_succeeded"
      redirect back
    else
      flash[:warning] = topic.errors.full_messages
      redirect back
    end
  end

  get "/c/:code/:id" do |code, topic_id|
    @city = City.find_by code: code.downcase
    @topic = Topic.find_by id: topic_id, city_id: @city.id
    @responses = Response.where(topic_id: topic_id).order("id ASC")
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
