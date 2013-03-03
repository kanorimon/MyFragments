class AddSeqToMemos < ActiveRecord::Migration
  def change
    add_column :memos, :seq, :integer
  end
end
