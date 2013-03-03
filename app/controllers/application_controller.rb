class ApplicationController < ActionController::Base

  # CSRF
  protect_from_forgery

  # ログインユーザhelper
  helper_method :current_user, :last_memo

  # ログインユーザ設定
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  # 読み込み最終行設定
  private
  def last_memo
    @last_memo ||= Memo.find(session[:last_memo_id]) if session[:last_memo_id]
  end
  
  # 読み込み最終行設定
  private
  def search_string
    @search_string = session[:search_string]
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

end
