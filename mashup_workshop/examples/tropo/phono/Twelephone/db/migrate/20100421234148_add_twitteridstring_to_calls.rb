class AddTwitteridstringToCalls < ActiveRecord::Migration
  def self.up
    add_column :calls, :twitterids, :string
  end

  def self.down
    remove_column :calls, :twitterids
  end
end
