# coding: utf-8
class UsersController < ApplicationController
  
  # ユーザー削除
  def destroy
    
    # ログインユーザーで特定
    @user = User.find(current_user.id)
    # ユーザー削除
    @user.destroy
    # session削除
    session[:user_id] = nil
    
    # indexにリダイレクト
    redirect_to root_url, :notice => "退会しました。"
  end

end
