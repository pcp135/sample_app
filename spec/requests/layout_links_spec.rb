require 'spec_helper'

describe "LayoutLinks" do

  it "should have the right links on the layout" do
    visit root_path
    click_link "About"
    response.should have_selector('title', :content => "About")
    click_link "Help"
    response.should have_selector('title', :content => "Help")
    click_link "Contact"
    response.should have_selector('title', :content => "Contact")
    click_link "Home"
    response.should have_selector('title', :content => "Home")
    click_link "Sign up now!"
    response.should have_selector('title', :content => "Signup")
  end

  it "should have a Home Page at '/'" do
    get '/'
    response.should have_selector('title', :content => "Home")
  end

  it "should have a Contact Page at '/contact'" do
    get '/contact'
    response.should have_selector('title', :content => "Contact")
  end

  it "should have a About Page at '/about'" do
    get '/about'
    response.should have_selector('title', :content => "About")
  end

  it "should have a Help Page at '/help'" do
    get '/help'
    response.should have_selector('title', :content => "Help")
  end

  it "should have a signup Page at '/signup'" do
    get '/signup'
    response.should have_selector('title', :content => "Signup")
  end

  describe "when not signed in" do
    it "should have a signin link" do
      visit root_path
      response.should have_selector("a", :href => signin_path,
                                    :content => "Sign in")
    end
  end

  describe "when signed in" do
    
    before(:each) do
      @user=Factory(:user, :email_confirmed => true)
      integration_sign_in(@user)
    end

    it "should have a signout link" do
      visit root_path
      response.should have_selector("a", :href => signout_path,
                                    :content => "Sign out")
    end

    it "should have a profile link" do
      visit root_path
      response.should have_selector("a", :href => user_path(@user),
                                    :content => "Profile")
    end

    it "users page should not have delete links" do
      visit users_path
      response.should_not have_selector("a", :content => "delete")
    end
  end
  
  describe "when admin user" do
    before(:each) do
      @admin=Factory(:user, :email_confirmed => true, :admin => true)
      integration_sign_in(@admin)
    end

    it "users page should have delete links" do
      visit users_path
      response.should have_selector("a", :content => "delete")
    end

  end

end
