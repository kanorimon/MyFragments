# coding: utf-8
class ContentsController < ApplicationController
  
  # index表示
  def index
    # ログイン中の場合
    if current_user
      # memo新規作成用
      @memo = Memo.new
      # ユーザーのmemoを表示
      @memos = Memo.where("user_id =?", current_user.id).order('id desc')
    end
  end

end
