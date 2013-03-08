# coding: utf-8
class ApplicationController < ActionController::Base

  # CSRF
  protect_from_forgery

  # 定数
  ERROR_COMMENT = "エラーが発生しました。再度投稿してください。"
  
  # ログインユーザhelper
  helper_method :current_user

  # ログインユーザ設定
  private
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  # session初期化
  def session_init
    session[:before_seq] = []
    session[:before_id] = []
    session[:last_memo_seq] = nil
    session[:search_string] = nil
    session[:tag_search_string] = nil
  end

  # 入力値の検証（メモ）
  def validate_memo(memo_text)
    error_comment = ""
    if memo_text.blank?
      error_comment = "空白のメモは登録できません。"
    end
    if memo_text.split(//u).length > 256
      error_comment = "メモは256文字まで投稿できます。"
    end
    return error_comment
  end

  # 入力値の検証（タグ）
  def validate_tag(tag_name)
    error_comment = ""
    tagary = tag_name.gsub(/　/," ").split(nil)
    if tagary.size > 16
       error_comment = "タグは16個まで設定できます。"
    end
    if tag_name.split(//u).length > 128
       error_comment = "タグは128文字まで設定できます。"
    end
    return error_comment
  end

  # タグ登録
  def create_tags(tag_name,memo_id)
    # 入力されたタグを空白で区切って配列として保存
    tagary = tag_name.gsub(/　/," ").split(nil)
    tagary.each{|tag|
      # タグの入力内容を設定
      @tag = Tag.new
      @tag.memo_id = memo_id
      @tag.name = tag
      # dbに保存
      @tag.save!
    }
  end
  
  # タグ削除
  def delete_tags(memo_id)
    @delete_tags = Tag.where('memo_id = ?',memo_id)
    @delete_tags.each{|delete_tag|
      delete_tag.destroy
    }
  end

  # メモと残メモカウント取得（通常）
  def get_memos

    # メモ取得用conditions作成
    @condition = Memo.get_conditions(current_user.id,session[:last_memo_seq])
    # メモ取得
    @memos = Memo.find_memos(@condition)

    # @memosが0件だった場合
    if @memos.blank?
      # 残メモカウントは0
      @count_memos = 0

    # @memosが0件でなかった場合
    else
      # 読み込んだ最終seqを設定
      session[:last_memo_seq] = @memos.last.seq
      # 残メモカウント用conditions作成
      @condition_count = Memo.get_conditions(current_user.id,@memos.last.seq)
      # 残メモカウント取得
      @count_memos = Memo.count_memos(@condition_count)
    end

    # 画面に表示されているseqを配列に追加
    before_seq_push(@memos)

    return @memos,@count_memos
  end

  # メモと残メモカウント取得（検索）
  def search_memos

    # メモ取得用conditions作成
    @condition = Memo.get_conditions_with_tags(current_user.id,session[:last_memo_seq],session[:search_string],session[:tag_search_string])
    # メモ取得
    @memos = Memo.find_memos_with_tags(@condition)

    # @memosが0件だった場合
    if @memos.blank?
      # 残メモカウントは0
      @count_memos = 0

    # @memosが0件でなかった場合
    else
      # 読み込んだ最終seqを設定
      session[:last_memo_seq] = @memos.last.seq
      # 残メモカウント用conditions作成
      @condition_count = Memo.get_conditions_with_tags(current_user.id,@memos.last.seq,session[:search_string],session[:tag_search_string])
      # 残メモカウント取得
      @count_memos = Memo.count_memos_with_tags(@condition_count)
    end

    # 画面に表示されているseqを配列に追加
    before_seq_push(@memos)

    return @memos,@count_memos
  end

  # 画面に表示されているseqを配列に追加
  def before_seq_push(memos)
    memos.each do |memo|
      session[:before_id].push(memo.id)
      session[:before_seq].push(memo.seq)
    end
  end


end