class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :facebookid
      t.string :name
      t.string :firstname
      t.string :lastname
      t.string :link
      t.string :gender
      t.string :email
      t.integer :timezone
      t.string :local
      t.boolean :verified
      t.string :token

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
