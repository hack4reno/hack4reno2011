class CreateReminders < ActiveRecord::Migration
  def self.up
    create_table :reminders do |t|
      t.string :name
      t.text :message
      t.datetime :appointment

      t.timestamps
    end
  end

  def self.down
    drop_table :reminders
  end
end
