require 'spec_helper'

describe "FriendlyForwardings" do

  describe "for a confirmed user" do
    it "should forward to the requested page after signin" do
      user                     = Factory(:user, :email_confirmed => true)
      visit edit_user_path(user)
      fill_in :email, :with    => user.email
      fill_in :password, :with => user.password
      click_button
      response.should render_template('users/edit')
    end
  end

  describe "for an unconfirmed user" do
    it "should forward to the root path" do
      user                     = Factory(:user, :email_confirmed => false)
      visit edit_user_path(user)
      fill_in :email, :with    => user.email
      fill_in :password, :with => user.password
      click_button
      response.should render_template root_path
    end
  end


end

