ActionMailer::Base.smtp_settings = {
  :address => "smtp.gmail.com",
  :port => 587,
  :domain => "gmail.com",
  :user_name => "pcp136",
  :password => "zxmrsgoddjqbnoqi",
  :authentication => "plain",
  :enable_startttls_auto => true
}
if Rails.env.development?
  ActionMailer::Base.default_url_options[:host] = "localhost:3000"
  Mail.register_interceptor(DevelopmentMailInterceptor)
else
  ActionMailer::Base.default_url_options[:host] = "young-wind-583.heroku.com"
end