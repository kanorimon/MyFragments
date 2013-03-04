# coding: utf-8
class ContentsController < ApplicationController
  
  # index表示
  def index
    # ログイン中の場合
    if current_user
      session[:last_memo_seq] = nil
      session[:before_seq] = []
      
      # memo新規作成用
      @memo = Memo.new
      # ユーザーのmemoを取得
      @condition = Memo.getConditions(current_user.id,session[:last_memo_seq])
      @memos = Memo.getMemos(@condition)
      if @memos.blank?
        @count_memos = 0
      else
        @condition_count = Memo.getConditions(current_user.id,@memos.last.seq)
        @count_memos = Memo.getMemosCount(@condition_count)
        session[:last_memo_seq] = @memos.last.seq
      end

      @load_more_option = "show"

      before_seq_push(@memos)

      respond_to do |format|
        format.html { render }
        format.json { render json: @memos }
        format.js
      end 
    end
  end
  
end
