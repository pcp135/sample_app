require 'spec_helper'

describe "PasswordResets" do 
  it "emails user when requesting password reset" do
    user = Factory(:user)
    visit signin_path
    click_link "password"
    fill_in "email", :with => user.email
    click_button "reset password"
    response.should render_template root_path
    response.should have_selector("div.flash", :content => "Email sent")
    last_email.to.should include(user.email)
  end

  it "user can still login with old password" do
    user = Factory(:user)
    visit signin_path
    click_link "password"
    fill_in "email", :with => user.email
    click_button "reset password"
    visit signin_path 
    fill_in "email", :with => user.email
    fill_in "password", :with => user.password
    click_button "Sign in"
    controller.should be_signed_in
  end

  it "does not email invalid user when requesting password reset" do
    visit signin_path
    click_link "password"
    fill_in "email", :with => "invalid user"
    click_button "reset password"
    response.should render_template root_path
    response.should have_selector("div.flash", :content => "Email sent")
    last_email.should be nil
  end
  
  it "updates the user password when confirmation matches" do
    user = Factory(:user, :password_reset_token => "Something", :password_reset_sent_at => 1.hour.ago)
    visit edit_password_reset_path(user.password_reset_token)
    fill_in "password", :with => "foobar"
    click_button "Change password"
    response.should have_selector("span", :content => "doesn't match confirmation")
    fill_in "Password confirmation", :with => "foobar"
    click_button "Change password"
    response.should have_selector("div", :content => "Password has been reset")
  end
  
  it "reports when the password reset token expired" do
    user = Factory(:user, :password_reset_token => "Something", :password_reset_sent_at => 5.hours.ago)
    visit edit_password_reset_path(user.password_reset_token)
    fill_in "password", :with => "foobar"
    fill_in "Password confirmation", :with => "foobar"
    click_button "Change password"
    response.should have_selector("div", :content => "Password reset has expired")
  end
  
  it "raises record not found when password token is invalid" do
    lambda {
      visit edit_password_reset_path("invalid")
    }.should raise_exception(ActiveRecord::RecordNotFound)
  end

end