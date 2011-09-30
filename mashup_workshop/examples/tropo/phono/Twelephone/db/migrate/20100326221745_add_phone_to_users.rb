class AddPhoneToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :phone, :string
  end

  def self.down
    remove_column :users, :phone
  end
end
