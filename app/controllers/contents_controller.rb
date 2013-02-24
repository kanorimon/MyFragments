# coding: utf-8
require "twitter"

class ContentsController < ApplicationController
  
  def index
    
  end
    
  def tweet
    Twitter.configure do |config|
      config.consumer_key       = ENV['CONSUMER_KEY']
      config.consumer_secret    = ENV['CONSUMER_SECRET']
      config.oauth_token        = current_user.token
      config.oauth_token_secret = current_user.secret
    end
    
    twitter_client = Twitter::Client.new
    twitter_client.update("テスト")
    
    redirect_to root_url
  end
end
