class RemoveTokenFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :token
  end

  def down
    add_column :users, :token, :string
  end
end
