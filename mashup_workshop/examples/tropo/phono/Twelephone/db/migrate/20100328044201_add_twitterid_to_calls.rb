class AddTwitteridToCalls < ActiveRecord::Migration
  def self.up
    add_column :calls, :twitterid, :integer
  end

  def self.down
    remove_column :calls, :twitterid
  end
end
