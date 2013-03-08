# coding: utf-8
class SessionsController < ApplicationController

  # session作成
  def create
    begin
      auth = request.env["omniauth.auth"]
      user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])

      if user.blank?
        User.transaction do
          user = User.create_with_omniauth(auth)
          Memo.transaction do
            Memo.new_user(user.id)
          end
        end
      end
      session[:user_id] = user.id
    rescue
      flash[:alert] = "ログインできませんでした。"
      redirect_to root_url
    
    else
    redirect_to root_url, :notice => "ログインしました。"
      
    end
     
  end

  # session削除
  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "ログアウトしました。"
  end
end
