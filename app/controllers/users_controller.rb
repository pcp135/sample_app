class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "Signup"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to @user
    else
      @title = "Signup"
      render 'new'
    end
  end

end
