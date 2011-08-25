class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy
  before_filter :signed_in_user, :only => [:new, :create]

  def following
    @title = "Following"
    @user = User.find_by_name(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find_by_name(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end

  def show
    @user = User.find_by_name(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "Signup"
  end

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
      UserMailer.registration_confirmation(@user).deliver
    else
      @title = "Signup"
      @user.password=""
      @user.password_confirmation=""
      render 'new'
    end
  end

  def edit
    @title = "Edit user"
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      @user.name = current_user.name
      render 'edit'
    end
  end

  def destroy
    if User.find_by_name(params[:id]) == current_user
      flash[:error] = "Cannot delete yourself"
    else
      User.find_by_name(params[:id]).destroy
      flash[:success] = "User deleted"
    end
    redirect_to users_path
  end

  private
  def correct_user
    @user = User.find_by_name(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end

  def signed_in_user
    redirect_to(root_path) if signed_in?
  end

end
