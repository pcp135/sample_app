require 'spec_helper'

describe "LayoutLinks" do

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
end
