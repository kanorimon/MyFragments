class AddSeqUniquenessIndex < ActiveRecord::Migration
  def up
    add_index :memos, :seq, :unique => true
  end

  def down
    remove_index :memos, :seq
  end
end
