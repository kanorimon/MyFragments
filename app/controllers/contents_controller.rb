# coding: utf-8
class ContentsController < ApplicationController
  
  # index表示
  def index
    # ログイン中の場合
    if current_user
      # memo新規作成用
      @memo = Memo.new
      # ユーザーのmemoを表示
      @memos = Memo.where("user_id =?", current_user.id).order('id desc').page(params[:page]).per(5)

      respond_to do |format|
        format.html { render }
        format.json { render json: @memos }
        format.js
      end 
    end
  end
  
end
