class FacebookTestUser
  include DataMapper::Resource

  property :id,            Serial
  property :open_graph_id, Integer
  property :email,         String
  property :password,      String
  property :access_token,  String
  property :login_url,     String
  
  class << self
    def from_facebook_response(facebook_response)
      facebook_response.map do |facebook_response_user|
        user = self.first(:open_graph_id => facebook_response_user["id"])
        p 'um'
        unless user
          p 'creating user'
          user = self.create(:open_graph_id => facebook_response_user["id"],
                             :access_token  => facebook_response_user["access_token"],
                             :login_url     => facebook_response_user["login_url"])
                          p user
          p self.all
        end
        user
      end
    end
  end
end
