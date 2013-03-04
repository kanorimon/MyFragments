# coding: utf-8
class Memo < ActiveRecord::Base
  # データ定義
  attr_accessible :text, :user_id, :tweet_flg, :tag_name, :seq
  # dbに存在しない項目の定義
  attr_accessor :tweet_flg, :tag_name
  # リレーション
  belongs_to :user
  has_many :tags, :dependent => :destroy

  validates :text, 
    :presence => true,
    :length => {:maximum => 140}

  MAX_NUM = 5

  # メモ取得
  def self.getConditions(user_id,last_memo_seq)
    @condition = []
    @condition.push([" user_id = ? ",user_id]) if user_id
    @condition.push([" seq < ? ",last_memo_seq]) if last_memo_seq

    @condition = self.flatten_conditions(@condition)
    logger.debug(@condition)     

    return @condition
  end
  
  # メモ取得
  def self.getMemos(condition)
    @memos = Memo.find(:all,:order => "seq DESC",:limit => MAX_NUM,:conditions => condition)
    return @memos
  end

  # メモ取得
  def self.getMemosCount(condition)
    @count_memos = Memo.count(:conditions => condition)
    return @count_memos
  end
  
  def self.flatten_conditions(conditions)
    return nil if conditions.empty?
    ps = []
    condition = conditions.collect do |c|
      next if c.size < 1
      ps += c[1..(c.size)]
      "( #{c[0]} )"
    end.delete_if { |c| c.blank? }.join(" #{"and"} ")
    [condition, ps].flatten unless condition.empty?
  end
  
end
