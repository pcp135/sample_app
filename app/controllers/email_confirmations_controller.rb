class EmailConfirmationsController < ApplicationController
  def new
  end
  
  def edit
    @user = User.find_by_email_confirmation_token!(params[:id])
    if @user.email_confirmation_sent_at < 2.days.ago
      @user.send_email_confirmation
      flash[:notice] = "You waited too long, a new activation mail has been sent!"
      redirect_to root_path
    elsif @user
      @user.email_confirmed = true
      @user.save :validate => false
      sign_in @user
      flash[:success]  = "Your account has been activated"
      redirect_to root_url
    else
      flash[:error] = "Account not recognised"
      redirect_to root_url
    end    
  end

end
