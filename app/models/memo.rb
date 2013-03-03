# coding: utf-8
class Memo < ActiveRecord::Base
  # データ定義
  attr_accessible :text, :user_id, :tweet_flg, :tag_name
  # dbに存在しない項目の定義
  attr_accessor :tweet_flg, :tag_name
  # リレーション
  belongs_to :user
  has_many :tags, :dependent => :destroy


end
