class RemoveParentMemoIdFromMemos < ActiveRecord::Migration
  def up
    remove_column :memos, :parent_memo_id
  end

  def down
    add_column :memos, :parent_memo_id, :integer
  end
end
