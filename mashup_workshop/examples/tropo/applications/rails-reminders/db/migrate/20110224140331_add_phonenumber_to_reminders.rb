class AddPhonenumberToReminders < ActiveRecord::Migration
  def self.up
    add_column :reminders, :phonenumber, :string
  end

  def self.down
    remove_column :reminders, :phonenumber
  end
end
