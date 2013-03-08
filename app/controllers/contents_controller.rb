# coding: utf-8
class ContentsController < ApplicationController
  
  # index表示
  def index

    # ログイン中の場合
    if current_user
      # 初期化
      session_init
      
      # memo新規作成用
      @memo = Memo.new
     
      # ユーザーのmemoを取得
      @memos,@count_memos = get_memos

      # もっと読むボタンのリンク先
      @load_more_option = "show"

      respond_to do |format|
        format.html { render }
        format.json { render json: @memos }
        format.js
      end
    end
  end
  
  def rule
  end

  def help
  end

  
end
