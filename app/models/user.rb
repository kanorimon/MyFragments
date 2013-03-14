# coding: utf-8
require 'open-uri'
class User < ActiveRecord::Base
  # データ定義
  attr_accessible :name, :provider, :uid, :nickname, :avatar
  # paperclip設定
  has_attached_file :avatar,:format => :jpeg, 
  :styles => { :original => "30x30>" },
  :storage => :s3,
  :s3_credentials => "#{Rails.root}/config/s3.yml",
  :path => ":attachment/:id/:style.:extension"

  # リレーション
  has_many :memos, :dependent => :destroy

  # omniauthでのuser作成       
  def self.create_with_omniauth(auth)
    create!do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.nickname = auth["info"]["nickname"]
      user.avatar = open(auth["info"]["image"])
    end
  end

end
