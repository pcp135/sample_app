class SessionsController < ApplicationController
  def new
    @title = "Sign in"
  end

  def create
    user = User.authenticate(params[:session][:email], 
                             params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid email/password combination."
      @title = "Sign in"
      render 'new'
    elsif !user.email_confirmed?
      user.send_email_confirmation
      flash[:error] = "Your account has not been activated yet, please check your email."
      redirect_to root_path
    else
      if params[:remember_me]
        sign_in user 
      else
        temp_sign_in user
      end
      redirect_back_or user
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

end
