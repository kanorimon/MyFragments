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

  # 一回あたりのメモ取得最大数
  MAX_NUM = 5

  # メモ取得時のconditions作成
  def self.get_conditions(user_id,last_memo_seq)
    @condition = []
    @condition.push([" user_id = ? ",user_id]) if user_id
    @condition.push([" seq < ? ",last_memo_seq]) if last_memo_seq

    @condition = self.flatten_conditions(@condition)
    logger.debug(@condition)     

    return @condition
  end
  
  # メモ取得
  def self.find_memos(condition)
    @memos = Memo.find(:all,:order => "seq DESC",:limit => MAX_NUM,:conditions => condition)
    return @memos
  end

  # 残メモ数取得
  def self.count_memos(condition)
    @count_memos = Memo.count(:conditions => condition)
    return @count_memos
  end

  # メモ取得時のconditions作成（タグ結合）
  def self.get_conditions_with_tags(user_id,last_memo_seq,search_strings,tag_search_string)
    @condition = []
    @condition.push([" memos.user_id = ? ",user_id]) if user_id
    @condition.push([" memos.seq < ? ",last_memo_seq]) if last_memo_seq

    unless search_strings.blank?
      search_string =  search_strings.gsub(/　/," ").split(nil)
      search_string.each do |s|
        @condition.push([" memos.text like ? or tags.name like ? ",'%' + s + '%','%' + s + '%']) if s
      end
    end

    @condition.push([" tags.name = ? ",tag_search_string]) if tag_search_string

    @condition = self.flatten_conditions(@condition)
    logger.debug(@condition)

    return @condition
  end
  
  # メモ取得（タグ結合）
  def self.find_memos_with_tags(condition)
    @memos = Memo.find(:all,:order => "memos.seq DESC",:limit => MAX_NUM,:conditions => condition,:include => :tags)
    return @memos
  end

  # 残メモ数取得（タグ結合）
  def self.count_memos_with_tags(condition)
    @count_memos = Memo.count(:conditions => condition,:include => :tags)
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
