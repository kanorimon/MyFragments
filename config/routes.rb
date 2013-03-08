Memoapp::Application.routes.draw do

  get "contents/index"

  resources :contents
  resources :sessions
  resources :memos
  resources :tags
    
  # root
  root :to => 'contents#index'
  
  # OmniAuth
  match "/auth/:provider/callback" => "sessions#create"

  # ログアウト
  match "/logout" => "sessions#destroy", :as => :logout
  # 退会
  match "/remove" => "users#destroy", :as => :remove

  # 利用規約
  match "/rule" => "contents#rule", :as => :rule
  # ヘルプ
  match "/help" => "contents#help", :as => :help

  # 検索
  match 'memos/find'
  match "/tags_find" => "memos#tag_find", :as => :tags_find

  # もっと読む
  match "/load_more" => "memos#show_list", :as => :load_more
  match "/load_find_more" => "memos#find_list", :as => :load_find_more
  match "/load_tag_find_more" => "memos#tag_find_list", :as => :load_tag_find_more

  # タグ更新
  match "/tags_input" => "tags#input", :as => :tags_input
  match "/tags_show" => "tags#show", :as => :tags_show

  # メモ更新
  match 'memos/update'
  match "/memos_input" => "memos#input", :as => :memos_input
  match "/memos_show" => "memos#show", :as => :memos_show

  # メモ並び替え
  match 'memos/reorder' => 'memos#reorder', :via => [:get, :post]


end
