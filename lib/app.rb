require 'rubygems'
require 'sinatra'
require 'sinatra/outputbuffer'
require 'curb-fu'
require 'json'

require File.expand_path('../models', __FILE__)

class FacebookTestUsers < Sinatra::Base
  use Rack::MethodOverride

  helpers Sinatra::OutputBuffer::Helpers

  set :erb, :layout => :'layout.html'
  set :views, File.dirname(__FILE__) + '/views'
  set :public, File.dirname(__FILE__) + '/public'
  
  get '/users' do
    facebook_response = JSON.parse(CurbFu.get("https://graph.facebook.com/#{app_id}/accounts/test-users?access_token=#{access_token}").body)
    users = FacebookTestUser.from_facebook_response(facebook_response["data"])
    erb :"users/index.html", :locals => { :users => users }
  end
  
  get '/users/new' do
    erb :"users/new.html"
  end
  
  post '/users/new' do
    facebook_response = JSON.parse(CurbFu.get("https://graph.facebook.com/#{app_id}/accounts/test-users?" +
      "installed=#{params["installed"] ? "true" : "false"}" +
      "&permissions=#{params["permissions"]}" +
      "&method=post" +
      "&access_token=#{access_token}").body)
    
    FacebookTestUser.create(
      :open_graph_id => facebook_response["id"],
      :email         => facebook_response["email"],
      :password      => facebook_response["password"],
      :access_token  => facebook_response["access_token"],
      :login_url     => facebook_response["login_url"]
    )

    redirect '/users'
  end
  
  delete '/users/:id' do |id|
    CurbFu.get("https://graph.facebook.com/#{id}?method=delete&access_token=#{access_token}")
    redirect '/users'
  end
  
  def access_token
    @access_token ||= /access_token=(.*)/.match(CurbFu.get("https://graph.facebook.com/oauth/access_token?client_id=#{app_id}&client_secret=#{app_secret}&grant_type=client_credentials").body)[1]
  end
  
  def app_id
    credentials["app_id"]
  end
  
  def app_secret
    credentials["app_secret"]
  end
  
  def credentials
    @credentials ||= JSON.parse(IO.read(File.expand_path('../../config/app_credentials.json', __FILE__)))
  end
end