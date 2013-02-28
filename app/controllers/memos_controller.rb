# coding: utf-8
require "twitter"
class MemosController < ApplicationController

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

    # rootにリダイレクト
    redirect_to root_url, notice: 'Diary was successfully created.'
    #else
    #redirect_to root_url, notice: 'Diary was error.'
    #end
  end
  
  # 文字列検索
  def find
    # 検索用エンティティ
    @memo = Memo.new
    # 文字列検索実行
    @memos = Memo.find(
      :all, 
      :order => "memos.id", 
      :conditions => ["(memos.text like ? or tags.name like ? ) and memos.user_id = ?",
        '%' + params[:search_string] + '%',
        '%' + params[:search_string] + '%',
        current_user.id], 
      :include => :tags
    )
    # indexを使って出力
    render 'contents/index.html.erb'
  end
  
end
