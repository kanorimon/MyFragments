class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :nickname, :token, :secret

  def self.create_with_omniauth(auth)
    create!do |user|

      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.nickname = auth["info"]["nickname"]
      user.token = auth['credentials']['token']
      user.secret = auth['credentials']['secret']
    end
  end

end
