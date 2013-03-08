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
    :length => {:maximum => 256}

  validates :seq, :uniqueness => true
  
  # 一回あたりのメモ取得最大数
  MAX_NUM = 15

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
    @memos_id = Memo.find(:all,:order => "memos.seq DESC",:limit => MAX_NUM,:conditions => condition,:include => :tags, :select => "memos.id")
    @memos = Memo.where(["id in (?)", @memos_id]).order("seq DESC")
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
  
  # 残メモ数取得（タグ結合）
  def self.new_user(user_id)
    texts = []
    texts[5] = "MyFragmentsへようこそ！"
    texts[4] = "【メモ】
投稿：左上のテキストエリアにメモを入力して鉛筆ボタンをクリック！256文字まで投稿できます。
編集：メモの右側のエディットボタンをクリック。
削除：メモの右側のゴミ箱ボタンをクリック。
並べ替え：メモの右側の移動ボタンをドラッグ＆ドロップ。"
    texts[3] = "【タグ】
設定：メモを登録する時に、テキストエリアの下の入力欄にタグを入力！16個（128文字）まで設定できます。
編集：メモの下のタグアイコンをクリック。"
    texts[2] = "【検索】
文字列検索：左側の入力欄に検索したい文字列入力して検索ボタンをクリック。
タグ検索：検索したいタグをクリック。"
    texts[1] = "【ユーザー】
ログアウト：右上のユーザー名からメニューを表示してログアウトをクリック。
退会：右上のユーザー名からメニューを表示して退会をクリック。退会時にメモはすべて消去します。"
    texts[0] = "今表示されているメモは不要になったら削除してください。削除後に操作方法のヒントが必要になった場合は、ヘルプをご覧ください。"

    tags = []
    tags[5] = []
    tags[5][1] = "ヘルプ"
    tags[5][0] = "システムメッセージ"
    tags[4] = []
    tags[4][2] = "メモ"
    tags[4][1] = "ヘルプ"
    tags[4][0] = "システムメッセージ"
    tags[3] = []
    tags[3][2] = "タグ"
    tags[3][1] = "ヘルプ"
    tags[3][0] = "システムメッセージ"
    tags[2] = []
    tags[2][2] = "検索"
    tags[2][1] = "ヘルプ"
    tags[2][0] = "システムメッセージ"
    tags[1] = []
    tags[1][2] = "ユーザー"
    tags[1][1] = "ヘルプ"
    tags[1][0] = "システムメッセージ"
    tags[0] = []
    tags[0][1] = "ヘルプ"
    tags[0][0] = "システムメッセージ"
    
    texts.each_with_index do |text,i|
      @first_memos = Memo.new
      @first_memos.user_id = user_id
      @first_memos.text = text
      # dbに保存
      @first_memos.save!

      # シーケンス番号を設定
      @first_memos.seq =  @first_memos.id
      @first_memos.save!

        tags[i].each_with_index do |tag,k|
          @first_tags = Tag.new
          @first_tags.memo_id = @first_memos.id
          @first_tags.name = tag
          # dbに保存
          @first_tags.save!
      end
    end
  end
  
end
