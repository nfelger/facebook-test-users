require File.expand_path('../../lib/app', __FILE__)

require 'rspec'
require 'rack/test'
include Rack::Test::Methods

set :environment, :test

def app
  @app ||= Rack::Builder.new do
    eval IO.read(File.expand_path('../../config.ru', __FILE__))
  end.to_app
end
