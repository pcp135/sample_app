require 'spec_helper'

describe "Users" do

  describe "signup" do

    describe "failure" do

      it "should not make a new user" do
        lambda do
          visit signup_path
          fill_in "Name", :with => ""
          fill_in "Email", :with => ""
          fill_in "Password", :with => ""
          fill_in "Password confirmation", :with => ""
          click_button
          response.should render_template('users/new')
          response.should have_selector("span", :class => "error")
        end.should_not change(User, :count)
      end
    end   
    
    describe "success" do
      
      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in "Name", :with => "ExampleUser"
          fill_in "Email", :with => "user@example.com"
          fill_in "Password", :with => "foobar"
          fill_in "Password confirmation", :with => "foobar"
          click_button
          response.should have_selector("div.flash.success", 
                                        :content => "Welcome")
        end.should change(User, :count).by(1)
      end
    end
  end

  describe "sign in/out" do
    
    describe "failure" do

      it "should not sign a user in" do
        visit signin_path
        fill_in :email, :with => ""
        fill_in :password, :with => ""
        click_button
        response.should have_selector("div.flash.error", 
                                      :content => "Invalid")
      end
    end
    
    describe "success" do
      
      it "should sign a confirmed user in and out" do
        integration_sign_in(Factory(:user, :email_confirmed => true))
        controller.should be_signed_in
        click_link "Sign out"
        controller.should_not be_signed_in
      end
    end
  end

  describe "profile settings" do
    before(:each) do
      @user = Factory(:user)
      integration_sign_in(@user)
    end

    it "should have a settings page with key attributes" do
      visit edit_user_path(@user)
      response.should have_selector("label", :content => "Name")
      response.should have_selector("label", :content => "Email")
      response.should have_selector("label", :content => "Password")
      response.should have_selector("label", :content => "Password confirmation")
      response.should have_selector("label", :content => "Notify me when I have new followers")      
    end  
    
    it "should change the mail_notifications setting if the user updates it" do
      visit edit_user_path(@user)
      fill_in "Password", :with => @user.password
      fill_in "Password confirmation", :with => @user.password
      fill_in "Notify me when I have new followers", :with => false
      click_button "Update"
      @user.reload
      @user.should_not be_follower_mail_notifications
    end

  end

end

