class AddPhonenumberToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :phonenumber, :string
  end

  def self.down
    remove_column :users, :phonenumber
  end
end
