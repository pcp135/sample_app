class UserMailer < ActionMailer::Base
  default :from => "pcp136@gmail.com"

  def password_reset(user)
    @user       = user
    mail :to    => user.email, :subject => "Password Reset"
  end

  def email_confirmation(user)
    @user       = user
    mail :to    => user.email, :subject => "Activate your account"
  end

  def follower_notification(user, follower)
    @user = user
    @follower = follower
    mail :to => user.email, :subject => "You have a new follower"
  end

end
