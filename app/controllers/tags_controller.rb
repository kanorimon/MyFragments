# coding: utf-8
class TagsController < ApplicationController

  def show
    @memo_id = params[:memo_id]    
    @tags = Tag.where('memo_id = ?',params[:memo_id])
    # ajax
    render 'tags/show.js.erb'
  end

  def input
    @memo_id = params[:memo_id]
    @tags = Tag.where('memo_id = ?', params[:memo_id])
    
    @print_tag = ""
    @tags.each{|tag|
      @print_tag = @print_tag.concat(tag.name).concat(" ")
    }

    render 'tags/input.js.erb'
    
  end

  def create
    begin
    # 入力値の検証
   @error_comment = "エラーが発生しました。再度投稿してください。"
    if params[:tag_names].split(//u).length > 100
       @error_comment = "タグは100文字まで設定できます。"
      raise
    end

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
    rescue
      render 'contents/error.js.erb'

    else
    # ajax
    render 'tags/show.js.erb'
   end
  end
end
