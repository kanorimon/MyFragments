# coding: utf-8
class ContentsController < ApplicationController
  
  # index表示
  def index
    # ログイン中の場合
    if current_user
      session[:last_memo_id] = nil
      session[:before_seq] = []
      
      # memo新規作成用
      @memo = Memo.new
      # ユーザーのmemoを取得
      @memos = getDefaultMemos
  
      # もっと読むの制御
      if @memos.blank?
        @count_memos = 0
      else
        @count_memos = getDefaultMemosCount(@memos.last.id)
        session[:last_memo_id] = @memos.last.id
      end
      @load_more_option = "show"

      @memos.each do |memo|
        session[:before_seq].push(memo.seq)
      end 

      respond_to do |format|
        format.html { render }
        format.json { render json: @memos }
        format.js
      end 
    end
  end
  
end
