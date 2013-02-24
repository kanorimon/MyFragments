class CreateMemos < ActiveRecord::Migration
  def change
    create_table :memos do |t|
      t.integer :user_id
      t.text :text
      t.integer :parent_memo_id

      t.timestamps
    end
  end
end
