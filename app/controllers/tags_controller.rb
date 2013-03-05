# coding: utf-8
class TagsController < ApplicationController

  # タグ表示
  def show
    # 画面制御用memo_id
    @memo_id = params[:memo_id]    
    # タグ取得
    @tags = Tag.where('memo_id = ?',params[:memo_id])
    render 'tags/show.js.erb'
  end

  # タグ入力表示
  def input
    # 画面制御用memo_id
    @memo_id = params[:memo_id]
    @tags = Tag.where('memo_id = ?', params[:memo_id])

    # 入力用タグ文字列設定
    @print_tag = ""
    @tags.each{|tag|
      @print_tag = @print_tag.concat(tag.name).concat(" ")
    }

    render 'tags/input.js.erb'
    
  end

  # タグ登録
  def create
    begin
      # 画面制御用memo_id
      @memo_id = params[:memo_id]
      logger.debug("*******************1")

      # デフォルトエラーコメント設定
      @error_comment = ERROR_COMMENT
      logger.debug("*******************2")

      # 入力値の検証
      if !(validate_tag(params[:tag_names]).blank?)
        @error_comment = validate_tag(params[:tag_names])
        raise
      end
      logger.debug("*******************3")
      
      # タグ削除
      delete_tags(params[:memo_id])

      # タグを登録
      create_tags(params[:tag_names],params[:memo_id])
      
      # 表示用タグの取得
      @tags = Tag.where('memo_id = ?',params[:memo_id])
    rescue
      render 'contents/error.js.erb'

    else
      render 'tags/show.js.erb'
    end
  end
end
