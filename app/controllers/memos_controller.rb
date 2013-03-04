# coding: utf-8
class MemosController < ApplicationController
  protect_from_forgery :except => ["reorder"]

  def showlist

    # ユーザーのmemoを取得
    @condition = Memo.getConditions(current_user.id,session[:last_memo_seq])
    @memos = Memo.getMemos(@condition)
    @condition_count = Memo.getConditions(current_user.id,@memos.last.seq)
    @count_memos = Memo.getMemosCount(@condition_count)
      
    before_seq_push(@memos)
    session[:last_memo_seq] = @memos.last.seq

    # ajax
    render 'contents/index.js.erb'

  end

  # メモ新規作成
  def create
    begin
    # デフォルトエラーコメント設定
    @error_comment = ERROR_COMMENT
    # 入力値の検証
   if !(validate_memo(params[:memo][:text]).blank?)
      @error_comment = validate_memo(params[:memo][:text])
     raise
   end
   if !(validate_tag(params[:memo][:tag_name]).blank?)
      @error_comment = validate_tag(params[:memo][:tag_name])
     raise
   end

    # メモの入力内容を設定
    @memo = Memo.new
    @memo.user_id = current_user.id
    @memo.text = params[:memo][:text]

    # dbに保存
    @memo.save!

    # シーケンス番号を設定
    @memo.seq = @memo.id
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

    # 表示用メモの取得
    @memos = Memo.find_by_id(@memo.id)
     
    rescue
      render 'contents/error.js.erb'

    else
      render 'memos/create.js.erb'
    end
  end
  
  # 文字列検索
  def find
    # 検索用エンティティ
    @memo = Memo.new
    # 文字列検索実行
    session[:last_memo_id] = nil

    session[:search_string] = params[:search_string]

    @memos = getFindMemos

    # もっと読むの制御
    if @memos.blank?
      @count_memos = 0
    else
      @count_memos = getFindMemosCount(@memos.last.id)
      session[:last_memo_id] = @memos.last.id
    end
    @load_more_option = "find"

  
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

    if @memos.blank?
      @count_memos = 0
    else
      @count_memos = getTagFindMemosCount(@memos.last.id)
      session[:last_memo_id] = @memos.last.id
    end

    @load_more_option = "tagfind"


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
    @memo_seqs = params[:memo]
    logger.debug("****************************************")
    logger.debug(@memo_seqs)
    logger.debug(session[:before_seq])
       
    @target_memoids =[]
    n = 0
    @memo_seqs.each_with_index do |seq,i|
      if seq != session[:before_seq][i]
        @target_memo = Memo.find_by_seq(session[:before_seq][i])
        @target_memo.seq = seq.to_i * -1
        @target_memo.save!

        @target_memoids.push(@target_memo.id)
         
        session[:before_seq][i] = seq

       end
    end

    @target_memoids.each do |ids|
       @memo = Memo.find_by_id(ids)
       @memo.seq = @memo.seq * -1
       @memo.save!
    end

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
