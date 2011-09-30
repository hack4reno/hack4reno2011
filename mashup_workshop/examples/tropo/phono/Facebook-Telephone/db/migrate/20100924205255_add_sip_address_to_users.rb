class AddSipAddressToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :sip, :string
  end

  def self.down
    remove_column :users, :sip
  end
end
