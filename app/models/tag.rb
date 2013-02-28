# coding: utf-8
class Tag < ActiveRecord::Base
  # データ定義
  attr_accessible :memo_id, :name
  # リレーション
  belongs_to :memo
end
