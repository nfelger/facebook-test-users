require 'spec_helper'

describe FacebookTestUsers do
  let(:new_user_response) do
    { :id           => 123,
      :access_token => 'abc123',
      :login_url    => 'http://example.com',
      :email        => 'asd@a.com',
      :password     => 'basketball'
    }.to_json
  end
  
  before do
    CurbFu.stub!(:get).and_return do |url|
      response = case url
      when %r{https://graph.facebook.com/[^/]*/accounts/test-users.*}
        new_user_response
      when %r{https://graph.facebook.com/oauth/access_token.*}
        'access_token=faketoken'
      else
        raise "Unregistered url. Can't have that, Dave."
      end
      mock('CurbFu::Response::Base', :body => response)
    end
  end
  
  it "should" do
    FacebookTestUser.should_receive(:create).with(hash_including({
      :open_graph_id => 123,
      :email         => 'asd@a.com',
      :password      => 'basketball'
    }))
    
    post '/users/new', {'permissions' => 'read_stream'}
    
    last_response.should be_redirect
  end
end