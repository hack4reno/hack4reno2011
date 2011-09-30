class AddFlagsToReminders < ActiveRecord::Migration
  def self.up
    add_column :reminders, :flag1, :boolean
    add_column :reminders, :flag2, :boolean
    add_column :reminders, :flag3, :boolean
  end

  def self.down
    remove_column :reminders, :flag3
    remove_column :reminders, :flag2
    remove_column :reminders, :flag1
  end
end
