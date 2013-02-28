# coding: utf-8
require 'open-uri'
class User < ActiveRecord::Base
  # データ定義
  attr_accessible :name, :provider, :uid, :nickname, :token, :secret, :avatar
  # paperclip設定
  has_attached_file :avatar,:format => :jpeg, :styles => { :thumb => "30x30>" }
  # postしたあと、画像のファイル名変更を起動
  before_post_process :transliterate_file_name
  # リレーション
  has_many :memos, :dependent => :destroy

  # omniauthでのuser作成       
  def self.create_with_omniauth(auth)
    create!do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["name"]
      user.nickname = auth["info"]["nickname"]
      user.token = auth['credentials']['token']
      user.secret = auth['credentials']['secret']
      user.avatar = open(auth["info"]["image"])
    end
  end

  # 画像のファイル名変更
  def transliterate_file_name
    extension = 'jpg'
    filename = self.nickname
    self.avatar.instance_write(:file_name, "#{filename}.#{extension}")
  end

end
