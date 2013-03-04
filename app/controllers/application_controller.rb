# coding: utf-8
class ApplicationController < ActionController::Base

  # CSRF
  protect_from_forgery

  MAX_NUM = 5
  ERROR_COMMENT = "エラーが発生しました。再度投稿してください。"
  
  # ログインユーザhelper
  helper_method :current_user

  # ログインユーザ設定
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  # 読み込み最終行設定
  private
  def last_memo
    @last_memo ||= Memo.find_by_seq(session[:last_memo_seq]) if session[:last_memo_seq]
  end
  
  # 読み込み最終行設定
  private
  def search_string
    @search_string = session[:search_string]
  end

  # 読み込み最終行設定
  private
  def before_seq
    @before_seq = session[:before_seq]
  end

  #入力値の検証（メモ）
  def validate_memo(memo_text)
    error_comment = ""
    if memo_text.blank?
      error_comment = "空白のメモは登録できません。"
    end
    if memo_text.split(//u).length > 140
      error_comment = "メモは140文字まで投稿できます。"
    end
    return error_comment
  end

  #入力値の検証（タグ）
  def validate_tag(tag_name)
    error_comment = ""
    tagary =  params[:memo][:tag_name].gsub(/　/," ").split(nil)
    if tagary.size > 10
       error_comment = "タグは10個まで設定できます。"
    end
    if params[:memo][:tag_name].split(//u).length > 100
       error_comment = "タグは100文字まで設定できます。"
    end
    return error_comment
  end


  def before_seq_push(memos)
    memos.each do |memo|
      session[:before_seq].push(memo.seq)
    end 
  end

  # 取得
  def getDefaultMemos
    if last_memo
      @memos = Memo.where("user_id =? and id < ?", current_user.id,last_memo.id).order('id desc').limit(5)    
    else
      @memos = Memo.where("user_id =?", current_user.id).order('id desc').limit(5)
    end

    return @memos
  end
   
  def getDefaultMemosCount(last_id)
    @count_memos = Memo.count(:conditions => ["user_id =? and id < ?", current_user.id,last_id])

    return @count_memos
  end
  

  # 取得
  def getFindMemos
  
    #keywordary =  search_string.gsub(/　/," ").split(nil)
    if last_memo
      @memos = Memo.find(
        :all, 
        :order => "memos.id DESC",
        :limit => 5,
        :conditions => ["(memos.text like ? or tags.name like ? ) and memos.user_id = ? and memos.id < ?",
          '%' + search_string + '%',
          '%' + search_string + '%',
          current_user.id,
            last_memo.id],  
        :include => :tags
       )
    else
      #@memos = Memo.search(:memos_text_cont_all => keywordary).result
      #@memos = @memos.order("memos.id desc").limit(5)

      @memos = Memo.find(
        :all, 
        :order => "memos.id DESC",
        :limit => 5,
        :conditions => ["(memos.text like ? or tags.name like ? ) and memos.user_id = ?",
          '%' + search_string + '%',
          '%' + search_string + '%',
          current_user.id], 
        :include => :tags
       )
    end

    return @memos
  end
   
  def getFindMemosCount(last_id)

    keywordary =  search_string.gsub(/　/," ").split(nil)
  
    @count_memos = Memo.count(
      :all, 
      :conditions => ["(memos.text like ? or tags.name like ? ) and memos.user_id = ? and memos.id < ?",
        '%' + search_string + '%',
        '%' + search_string + '%',
        current_user.id,
        last_id], 
      :include => :tags
      )

    return @count_memos
  end


  # 取得
  def getTagFindMemos
    if last_memo
     @memos = Memo.find(
      :all, 
      :order => "memos.id DESC",
      :limit => 5,
      :conditions => ["tags.name = ? and memos.user_id = ? and memos.id < ?",
        search_string,
        current_user.id,
        last_memo.id], 
      :include => :tags
      )
    else
      @memos = Memo.find(
        :all, 
        :order => "memos.id DESC",
        :limit => 5,
        :conditions => ["tags.name = ? and memos.user_id = ?",
          search_string,
          current_user.id], 
        :include => :tags
       )
    end

    return @memos
  end
   
  def getTagFindMemosCount(last_id)
    @count_memos = Memo.count(
      :all, 
      :conditions => ["tags.name = ? and memos.user_id = ? and memos.id < ?",
        search_string,
        current_user.id,
        last_id], 
      :include => :tags
      )

    return @count_memos
  end

end
