# coding: utf-8
class TagsController < ApplicationController

  def create
    @memo_id = params[:memo_id]
    
    @delete_tags = Tag.where('memo_id = ?',params[:memo_id])
    @delete_tags.each{|delete_tag|
      delete_tag.destroy
     }
    
    # 入力されたタグを空白で区切って配列として保存
    tagary =  params[:tag_names].gsub(/　/," ").split(nil)
    tagary.each{|tag|
      # タグの入力内容を設定
      @tag = Tag.new
      @tag.memo_id = params[:memo_id]
      @tag.name = tag
      # dbに保存
      @tag.save!
     }
     
     @tags = Tag.where('memo_id = ?',params[:memo_id])
    # ajax
    render 'contents/taginsert.js.erb'
     
  end
end
