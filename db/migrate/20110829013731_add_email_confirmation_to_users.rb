class AddEmailConfirmationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :email_confirmation_token, :string
    add_column :users, :email_confirmation_sent_at, :datetime
    add_column :users, :email_confirmed, :boolean, :default => false
  end

  def self.down
    remove_column :users, :email_confirmed
    remove_column :users, :email_confirmation_sent_at
    remove_column :users, :email_confirmation_token
  end
end
