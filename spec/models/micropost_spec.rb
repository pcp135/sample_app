require 'spec_helper'

describe Micropost do

  before(:each) do
    @user = Factory(:user)
    @attr = { :content => "value for content" }
  end

  it "should create a new instance given valid attributes" do
    @user.microposts.create!(@attr)
  end
      
  describe "user associations" do
    
    before(:each) do
      @micropost = @user.microposts.create(@attr)
    end

    it "should have a user attribute" do
      @micropost.should respond_to(:user)
    end

    it "should have the right associated user" do
      @micropost.user_id.should == @user.id
      @micropost.user.should == @user
    end
  end

  describe "micropost associations" do
    
    before(:each) do
      @user = User.create(@attr)
    end

    it "should have a microposts attribute" do
      @user.should respond_to(:microposts)
    end
  end

  describe "validations" do
    
    it "should require a user id" do
      Micropost.new(@attr).should_not be_valid
    end

    it "should require nonblank content" do
      @user.microposts.build(:content => "  ").should_not be_valid
    end

    it "should reject long content" do
      @user.microposts.build(:content => "a" *141).should_not be_valid
    end
  end

  describe "from_users_followed_by" do

    before(:each) do
      @other_user = Factory(:user)
      @third_user = Factory(:user)

      @user_post = @user.microposts.create!(:content => "foo")
      @other_post = @other_user.microposts.create!(:content => "bar")
      @third_post = @third_user.microposts.create!(:content => "baz")
     
      @user.follow!(@other_user)
    end

    it "should have a from_users_followed_by class method" do
      Micropost.should respond_to(:from_users_followed_by)
    end

    it "should include the followed user's microposts" do
      Micropost.from_users_followed_by(@user).should include(@other_post)
    end

    it "should include the user's own microposts" do
      Micropost.from_users_followed_by(@user).should include(@user_post)
    end

    it "should not include an unfollowed user's microposts" do
      Micropost.from_users_followed_by(@user).
        should_not include(@third_post)
    end
    
    it "should not include a reply that isn't for the user" do
      @reply_post = @other_user.microposts.create!(
      :content => "@#{@third_user.name} reply")
      @reply_post.replying?
      Micropost.from_users_followed_by(@user).
      should_not include(@reply_post)
    end
    
    it "should include the user replying to another user" do
      @reply_post = @user.microposts.create!(
      :content => "@#{@other_user.name} reply")
      @reply_post.replying?
      Micropost.from_users_followed_by(@user).should include(@reply_post)
    end
    
    it "should include someone else replying to the user" do
      @reply_post = @other_user.microposts.create!(
      :content => "@#{@user.name} reply")
      @reply_post.replying?
      Micropost.from_users_followed_by(@user).should include(@reply_post)
    end

  end

  describe "in_reply_to" do
    
    before(:each) do
      @micropost = @user.microposts.create!(@attr)
    end

    it "should be present" do
      @micropost.should respond_to(:in_reply_to)
    end
    
    it "should have a replying? method" do
      @micropost.should respond_to(:replying?)
    end
    
    it "should not be populated where not replying" do
      @micropost.replying?
      @micropost.in_reply_to.should be_nil
    end
    
    it "should be populated where replying" do
      @other_user = Factory(:user)
      @reply_post = @user.microposts.create!(:content => "@#{@other_user.name} I am replying")
      @reply_post.replying?
      @reply_post.in_reply_to.should == @other_user.id
    end
    
    it "should not be populated if user doesn't exist" do
      @reply_post = @user.microposts.create!(:content => "@false I am replying")
      @reply_post.replying?
      @reply_post.in_reply_to.should be_nil      
    end
        
  end

end
