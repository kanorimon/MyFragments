class Memo < ActiveRecord::Base
  attr_accessible :parent_memo_id, :text, :user_id, :tweet_flg
  attr_accessor :tweet_flg
  belongs_to :user

end
