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
    begin
    # メモの入力内容を設定
    @memo = Memo.new
    # 入力値の検証
   @error_comment = "エラーが発生しました。再度投稿してください。"
    if params[:memo][:text].blank?
       @error_comment = "空白のメモは登録できません。"
      raise
    end
    if params[:memo][:text].split(//u).length > 140
       @error_comment = "メモは140文字まで投稿できます。"
      raise
    end
    if params[:memo][:tag_name].split(//u).length > 100
       @error_comment = "タグは100文字まで設定できます。"
      raise
    end

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

    @memos = Memo.find_by_id(@memo.id)
     
    rescue
      render 'contents/error.js.erb'

    else
      render 'memos/create.js.erb'
    end
=begin    
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
=end
    # ajax

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


  # 文字列検索
  def tagfind
    # 検索用エンティティ
    @memo = Memo.new
    # 文字列検索実行
    session[:last_memo_id] = nil

    session[:search_string] = params[:tag_name]

    @memos = getTagFindMemos

    @count_memos = getTagFindMemosCount(@memos.last.id)
    @load_more_option = "tagfind"

    session[:last_memo_id] = @memos.last.id

    # indexを使って出力
    render 'contents/index.html.erb'
  end
  
  def tagfindlist
 
    @memos = getTagFindMemos

    @count_memos = getTagFindMemosCount(@memos.last.id)
    
    session[:last_memo_id] = @memos.last.id

    # ajax
    render 'contents/index.js.erb'

  end
  
  def index
    @memos = Memo.where("user_id =?", current_user.id).order('id desc').order('seq')
  end

  def reorder
    params[:memo].each_with_index{|row, i| Memo.update(row, {:seq => i + 1})}
    render :nothing => true
  end
  
  def destroy

    @delete_memo_id = params[:id]
    logger.debug(@delete_memo_id)
    
    @memo = Memo.find(params[:id])
    @memo.destroy
    
    # ajax
    render 'memos/delete.js.erb'
  end
  
end
