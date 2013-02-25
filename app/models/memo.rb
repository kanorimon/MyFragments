class Memo < ActiveRecord::Base
  attr_accessible :text, :user_id, :tweet_flg, :tag_name
  attr_accessor :tweet_flg, :tag_name
  belongs_to :user
  has_many :tags
end
