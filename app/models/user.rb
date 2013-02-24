require 'open-uri'
class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid, :nickname, :token, :secret
  attr_accessible :avatar
  has_attached_file :avatar,:format => :jpeg, :styles => { :thumb => "50x50>" }
  before_post_process :transliterate_file_name

  def self.create_with_omniauth(auth)
    create!do |user|

      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.nickname = auth["info"]["nickname"]
      user.token = auth['credentials']['token']
      user.secret = auth['credentials']['secret']

      logger.debug(auth["info"]["image"])
      user.avatar = open(auth["info"]["image"])
    end
  end
 
  def transliterate_file_name
    extension = 'jpg'
    filename = self.nickname
    self.avatar.instance_write(:file_name, "#{filename}.#{extension}")
  end

end
