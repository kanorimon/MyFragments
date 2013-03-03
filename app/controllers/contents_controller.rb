# coding: utf-8
class ContentsController < ApplicationController
  
  # index表示
  def index
    # ログイン中の場合
    if current_user
      # memo新規作成用
      @memo = Memo.new
      # ユーザーのmemoを表示
      @memos = Memo.where("user_id =?", current_user.id).order('id desc').limit(5)
      session[:last_memo_id] = @memos.last.id

      @count_memos = Memo.count(:conditions => ["user_id =? and id < ?", current_user.id,@memos.last.id])
      @load_more_option = "show"

      respond_to do |format|
        format.html { render }
        format.json { render json: @memos }
        format.js
      end 
    end
  end
  
end
