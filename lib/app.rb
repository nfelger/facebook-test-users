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
  
  get '/' do
    p settings.environment
    File.read(File.expand_path('../views/index.html', __FILE__)).sub('__FACEBOOK_APP_ID__', config['app_id'])
  end
  
  get '/apps/:app_id/test_users' do |app_id|
    facebook_response = JSON.parse(CurbFu.get("https://graph.facebook.com/#{app_id}/accounts/test-users?access_token=#{params[:access_token]}").body)
    users = FacebookTestUser.from_facebook_response(facebook_response["data"])
    users.to_json
  end
  
  post '/app/:app_id/test_users' do |app_id|
    facebook_response = JSON.parse(CurbFu.get("https://graph.facebook.com/#{app_id}/accounts/test-users?" +
      "installed=#{params["installed"] ? "true" : "false"}" +
      "&permissions=#{params["permissions"] || "read_stream"}" +
      "&method=post" +
      "&access_token=#{params["access_token"]}").body)
    
    user = FacebookTestUser.create(
      :open_graph_id => facebook_response["id"],
      :email         => facebook_response["email"],
      :password      => facebook_response["password"],
      :access_token  => facebook_response["access_token"],
      :login_url     => facebook_response["login_url"]
    )

    user.to_json
  end
  
  delete '/test_users/:user_id' do |user_id|
    CurbFu.get("https://graph.facebook.com/#{user_id}?method=delete&access_token=#{params["access_token"]}")
  end
  
  get '/access_token' do
    token = /access_token=(.*)/.match(CurbFu.get("https://graph.facebook.com/oauth/access_token?callback=?&client_id=#{params[:app_id]}&client_secret=#{params[:app_secret]}&grant_type=client_credentials").body)[1]
    {:accessToken => token}.to_json
  end
  
  private
  
  def config
    @config ||= JSON.parse(IO.read(File.expand_path('../../app_config.json', __FILE__)))[settings.environment.to_s]
  end
end