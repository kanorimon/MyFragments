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

end
