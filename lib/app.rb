require 'sinatra'
require 'curb-fu'
require 'json'

get '/users' do
  CurbFu.get("https://graph.facebook.com/#{app_id}/accounts/test-users?access_token=#{access_token}").body
end

get '/users/new' do
  erb :"users/new.html"
end

post '/users/new' do
  CurbFu.get("https://graph.facebook.com/#{app_id}/accounts/test-users?" +
    "installed=#{params["installed"] ? "true" : "false"}" +
    "&permissions=#{params["permissions"]}" +
    "&method=post" +
    "&access_token=#{access_token}").body
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