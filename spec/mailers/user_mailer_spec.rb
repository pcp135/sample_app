require "spec_helper"

describe UserMailer do
  describe "password_reset" do
    let(:user) { Factory(:user, :password_reset_token => "testToken") }
    let(:mail) { UserMailer.password_reset(user) }
    
    it "sends user password reset url" do
      mail.subject.should eq("Password Reset")
      mail.to.should eq([user.email])
      mail.body.encoded.should match(edit_password_reset_path(user.password_reset_token))
    end
  end
  
  describe "follower_notification" do
    it "should send a proper follower_notification" do
      user = Factory(:user)
      follower = Factory(:user)
      follower.follow!(user)
      last_email.subject.should eq("You have a new follower")
      last_email.to.should eq([user.email])
      last_email.body.encoded.should match(follower.name)
      last_email.body.encoded.should match(user_path(follower))      
    end
  end
end