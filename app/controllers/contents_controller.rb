# coding: utf-8
require "twitter"

class ContentsController < ApplicationController
  
  def index
    if current_user
      @memo = Memo.new
      @memos = Memo.where("user_id =?", current_user.id).order('id desc')
    end

  end
  
  def create
    @memo = Memo.new
    @memo.user_id = current_user.id
    @memo.text = params[:memo][:text]

    @memo.save!

    tagary =  params[:memo][:tag_name].gsub(/　/," ").split(nil)
    tagary.each{|tag|
      @tag = Tag.new
      @tag.memo_id = @memo.id
      @tag.name = tag
      @tag.save!
     }
     
     logger.debug "*****************" + params[:memo][:tweet_flg]
    if params[:memo][:tweet_flg] == "true"
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
        #else
        #redirect_to root_url, notice: 'Diary was error.'
        #end
  end  
  
  def find
      @memo = Memo.new
@memos = Memo.find(
  :all, 
  :order => "memos.id", 
  :conditions => ["tags.name =?", params[:search_string]], 
  :include => :tags
)

    render 'contents/index.html.erb'

  end
  
  
  def userdestroy
    
    @user = User.find(current_user.id)
    @user.destroy
    session[:user_id] = nil
redirect_to root_url

  end
end
