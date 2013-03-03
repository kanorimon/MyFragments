# coding: utf-8
require "twitter"
class MemosController < ApplicationController
  
  def showlist
    # ユーザーのmemoを取得
    @memos = getDefaultMemos

    # もっと読むの制御
    @count_memos = getDefaultMemosCount(@memos.last.id)
    
    session[:last_memo_id] = @memos.last.id

    # ajax
    render 'contents/index.js.erb'

  end

  # メモ新規作成
  def create
    # メモの入力内容を設定
    @memo = Memo.new
    @memo.user_id = current_user.id
    @memo.text = params[:memo][:text]

    # dbに保存
    @memo.save!

    # 入力されたタグを空白で区切って配列として保存
    tagary =  params[:memo][:tag_name].gsub(/　/," ").split(nil)
    tagary.each{|tag|
      # タグの入力内容を設定
      @tag = Tag.new
      @tag.memo_id = @memo.id
      @tag.name = tag
      # dbに保存
      @tag.save!
     }
     
    # twitter_flgが"true"の場合
    if params[:memo][:tweet_flg] == "true"
      # twitterに投稿
      Twitter.configure do |config|
        config.consumer_key       = ENV['CONSUMER_KEY']
        config.consumer_secret    = ENV['CONSUMER_SECRET']
        config.oauth_token        = current_user.token
        config.oauth_token_secret = current_user.secret
      end
      twitter_client = Twitter::Client.new
      twitter_client.update(params[:memo][:text])
    end

    # ajax
    @memos = Memo.find_by_id(@memo.id)
    render 'contents/create.js.erb'
    # rootにリダイレクト
    # redirect_to root_url, notice: 'Diary was successfully created.'
    #else
    #redirect_to root_url, notice: 'Diary was error.'
    #end
  end
  
  # 文字列検索
  def find
    # 検索用エンティティ
    @memo = Memo.new
    # 文字列検索実行
    session[:last_memo_id] = nil

    session[:search_string] = params[:search_string]

    @memos = getFindMemos

    @count_memos = getFindMemosCount(@memos.last.id)
    @load_more_option = "find"

    session[:last_memo_id] = @memos.last.id

    # indexを使って出力
    render 'contents/index.html.erb'
  end
  
  def findlist
 
    @memos = getFindMemos

    @count_memos = getFindMemosCount(@memos.last.id)
    
    session[:last_memo_id] = @memos.last.id

    # ajax
    render 'contents/index.js.erb'

  end
  
  def destroy

    @delete_memo_id = params[:id]
    logger.debug(@delete_memo_id)
    
    @memo = Memo.find(params[:id])
    @memo.destroy
    
    # ajax
    render 'contents/delete.js.erb'
  end
  
end
