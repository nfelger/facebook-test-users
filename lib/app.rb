require 'sinatra'
require 'curb-fu'
require 'json'

get '/users' do
  CurbFu.get("https://graph.facebook.com/#{credentials["app_id"]}/accounts/test-users?access_token=#{access_token}").body
end

def access_token
  /access_token=(.*)/.match(CurbFu.get("https://graph.facebook.com/oauth/access_token?client_id=#{credentials["app_id"]}&client_secret=#{credentials["app_secret"]}&grant_type=client_credentials").body)[1]
end

def credentials
  @credentials ||= JSON.parse(IO.read(File.expand_path('../../config/app_credentials.json', __FILE__)))
end