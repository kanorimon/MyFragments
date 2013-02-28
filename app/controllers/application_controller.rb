class ApplicationController < ActionController::Base

  # CSRF
  protect_from_forgery

  # ログインユーザhelper
  helper_method :current_user

  # ログインユーザ設定
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

end
