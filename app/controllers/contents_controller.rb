# coding: utf-8
require "twitter"

class ContentsController < ApplicationController
  
  def index
    if current_user
      @memo = Memo.new
      @memos = Memo.where("user_id =?", current_user.id) 
    end

  end
  
  def create
    @memo = Memo.new(params[:memo])
    @memo.user_id = current_user.id
    @memo.text = params[:memo][:text]
    @memo.parent_memo_id = 0

    # logger("test")
    # logger(@memo.tweet_flg)
    
    if @memo.save
      if params[:memo][:tweet_flg]
        logger.debug "tweetします"
        Twitter.configure do |config|
          config.consumer_key       = ENV['CONSUMER_KEY']
          config.consumer_secret    = ENV['CONSUMER_SECRET']
          config.oauth_token        = current_user.token
          config.oauth_token_secret = current_user.secret
        end
    
        twitter_client = Twitter::Client.new
        twitter_client.update(params[:memo][:text])
        
      end
      redirect_to root_url, notice: 'Diary was successfully created.'
    else
      redirect_to root_url, notice: 'Diary was error.'
    end
  end  
  
  def tweet
    
    Memo.create(params)
    
=begin
    Twitter.configure do |config|
      config.consumer_key       = ENV['CONSUMER_KEY']
      config.consumer_secret    = ENV['CONSUMER_SECRET']
      config.oauth_token        = current_user.token
      config.oauth_token_secret = current_user.secret
    end
    
    twitter_client = Twitter::Client.new
    twitter_client.update("テスト")
=end
    
    redirect_to root_url
  end
end
