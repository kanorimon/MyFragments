# coding: utf-8
class MemosController < ApplicationController
  protect_from_forgery :except => ["reorder"]

  # メモ一覧（もっと読む）
  def show_list
    # ユーザーのmemoを取得
    @memos,@count_memos = get_memos
    # 画面表示
    render 'contents/index.js.erb'
  end
  
  # 文字列検索
  def find
    # 初期化
    session_init
    # memo新規作成用
    @memo = Memo.new
    # 検索文字列をsessionに設定
    session[:search_string] = params[:search_string]
    # メモ検索
    @memos,@count_memos = search_memos
    # もっと読むボタンのリンク先
    @load_more_option = "find"
    # 画面表示
    render 'contents/index.html.erb'
  end

  # 文字列検索（もっと読む）
  def find_list
    # メモ検索
    @memos,@count_memos = search_memos
    # 画面表示
    render 'contents/index.js.erb'
  end

  # タグ検索
  def tag_find
    # 初期化
    session_init
    # memo新規作成用
    @memo = Memo.new
    # 検索文字列をsessionに設定
    session[:tag_search_string] = params[:tag_name]
    # メモ検索
    @memos,@count_memos = search_memos
    # もっと読むボタンのリンク先
    @load_more_option = "tag_find"
    # 画面表示
    render 'contents/index.html.erb'
  end
  
  # タグ検索（もっと読む）
  def tag_find_list
    # メモ検索
    @memos,@count_memos = search_memos
    # 画面表示
    render 'contents/index.js.erb'
  end
  
  # ajaxによる並べ替え
  def reorder
    @memo_seqs = params[:memo]
    logger.debug("****************************************")
    logger.debug(@memo_seqs)
    logger.debug(session[:before_seq])

    @before_seq_clone = session[:before_seq].clone()
    @before_seq_clone.sort!
    @before_seq_clone.reverse!

    logger.debug(@before_seq_clone)
     
    @target_memoids =[]
    n = 0
    @memo_seqs.each_with_index do |seq,i|
    logger.debug("*****************")
    logger.debug(seq)
    logger.debug(i)
    logger.debug(session[:before_seq][i])
      
      if seq != @before_seq_clone[i]
        
        @target_memo = Memo.find_by_seq(seq)
        @target_memo.seq = @before_seq_clone[i].to_i * -1
        @target_memo.save!

        @target_memoids.push(@target_memo.id)

       end
        session[:before_seq][i] = @before_seq_clone[i]

    end

    logger.debug(session[:before_seq])

    @target_memoids.each do |ids|
       @memo = Memo.find_by_id(ids)
       @memo.seq = @memo.seq * -1
       @memo.save!
    end

    render :nothing => true
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
      
      # メモを登録
      @memo = memo_save_with_seq(params[:memo][:text])

      # タグを登録
      create_tags(params[:memo][:tag_name],@memo.id)

      # 表示用メモの取得
      @memos = Memo.find_by_id(@memo.id)
      
      # 画面に表示されているseqに追加
      session[:before_seq].unshift(@memo.seq)
      
    rescue
      render 'contents/error.js.erb'

    else
      render 'memos/create.js.erb'
    end
  end
  
  
  # メモ登録
  def memo_save_with_seq(text)
    # メモの入力内容を設定
    @memo = Memo.new
    @memo.user_id = current_user.id
    @memo.text = text

    # dbに保存
    @memo.save!

    # シーケンス番号を設定
    @memo.seq = @memo.id
    @memo.save!
    
    return @memo
  end
  
  # メモ削除
  def destroy

    @delete_memo_id = params[:id]
    
    @memo = Memo.find(params[:id])

    # 画面に表示されているseqを削除
    session[:before_seq].delete(@memo.seq)

    @memo.destroy
    
    # ajax
    render 'memos/delete.js.erb'
  end
  
    # メモ表示
  def show
    # 画面制御用memo_id
    @memo_id = params[:memo_id]    
    # タグ取得
    @memo_text = Memo.find(params[:memo_id]).text
    render 'memos/show.js.erb'
  end

  # メモ入力表示
  def input
    # 画面制御用memo_id
    @memo_id = params[:memo_id]
    @memo_text = Memo.find(params[:memo_id]).text

    render 'memos/input.js.erb'
    
  end
  
  
  # メモ更新
  def update
    begin
      # 画面制御用memo_id
      @memo_id = params[:memo_id]
      @memo_text = params[:memo_text]

      # デフォルトエラーコメント設定
      @error_comment = ERROR_COMMENT

      # 入力値の検証
      if !(validate_memo(params[:memo_text]).blank?)
        @error_comment = validate_memo(params[:memo_text])
        raise
      end

      # メモを更新
      @memo = Memo.find(params[:memo_id])
      @memo.text = params[:memo_text]
      @memo.save!
      
    rescue
      render 'contents/error.js.erb'

    else
      render 'memos/show.js.erb'
    end
  end
  
end
