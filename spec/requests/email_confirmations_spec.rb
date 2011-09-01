require 'spec_helper'

describe 'email_confirmations' do
  before(:each) do
    @attr = {:name => "dummy", :email => "dummy@dummy.com", 
      :password => "foobar"}
  end

  it "emails the user when creating a new account" do
    visit signup_path
    fill_in "Name", :with => @attr[:name]
    fill_in "Email", :with => @attr[:email]
    fill_in "Password", :with => @attr[:password]
    fill_in "Password confirmation", :with => @attr[:password]
    click_button "Sign up"
    response.should render_template "email_confirmations/new"
    response.should have_selector("div.flash", :content => "Welcome to the Sample App!")
    last_email.to.should include(@attr[:email])    
  end  
  
  it "activates the user when email confirmation is valid" do
    user = Factory(:user, :email_confirmation_token => "ValidToken",
    :email_confirmation_sent_at => 1.hour.ago, :email_confirmed => false)
    visit edit_email_confirmation_path(user.email_confirmation_token)
    user.reload
    user.should be_email_confirmed
    controller.should be_signed_in
    response.should render_template root_path
  end

  it "doesn't activate the user when email confirmation is too old" do
    user = Factory(:user, :email_confirmation_token => "ValidToken",
    :email_confirmation_sent_at => 3.days.ago, :email_confirmed => false)
    visit edit_email_confirmation_path(user.email_confirmation_token)
    user.reload
    user.should_not be_email_confirmed
    controller.should_not be_signed_in
    response.should render_template root_path
    user.email_confirmation_token.should_not == "ValidToken"
    response.should have_selector("div", :content => "waited too long")
  end

  it "does not activate the user when email confirmation is invalid" do
    lambda {
      visit edit_email_confirmation_path("invalid")
    }.should raise_exception(ActiveRecord::RecordNotFound)
  end
    
end