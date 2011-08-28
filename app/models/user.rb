# == Schema Information
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  email              :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  encrypted_password :string(255)
#

require 'digest'

class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :email, :password, :password_confirmation

  has_many :microposts, :dependent => :destroy
  has_many(:relationships, :foreign_key => "follower_id",
           :dependent => :destroy)
  has_many(:following, :through => :relationships, 
           :source => :followed)
  has_many(:reverse_relationships, :foreign_key => "followed_id",
           :class_name => "Relationship", :dependent => :destroy)
  has_many(:followers, :through => :reverse_relationships,
           :source => :follower)

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  name_regex = /\A[\w+\-.]+\z/i

  validates_presence_of :name, :email
  validates_presence_of :password, :on => :create
  validates_presence_of :password, :on => :update
  validates_format_of :name, :with => name_regex
  validates_format_of :email, :with => email_regex
  validates_length_of :name, :maximum => 50
  validates_length_of :password, :within => 6..40, :on => :create
  validates_length_of :password, :within => 6..40, :on => :update
  validates_uniqueness_of :name, :email, :case_sensitive => false
  validates_confirmation_of :password, :on => :create
  validates_confirmation_of :password, :on => :update
  
  #validates :name, :presence => true, :length => { :maximum => 50}, 
  #:uniqueness => { :case_sensitive => false }, 
  #:format => { :with => name_regex }
  #validates :email, :presence => true, :format => { :with => email_regex }, 
  #:uniqueness => { :case_sensitive => false }
  #validates :password, :presence => true, :confirmation => true, 
  #:length => { :within => 6..40 }

  before_save :encrypt_password

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save false
    UserMailer.password_reset(self).deliver
  end
  
  def feed
    Micropost.from_users_followed_by(self)
  end

  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end

  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end

  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
  def to_param
    "#{name}"
  end
  
  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
  
  private
  
  def encrypt_password
    self.salt = make_salt if new_record?
    self.encrypted_password = encrypt(password)
  end

  def encrypt(string)
    secure_hash("#{salt}--#{string}")
  end

  def make_salt
    secure_hash("#{Time.now.utc}--#{password}")
  end

  def secure_hash(string)
    Digest::SHA2.hexdigest(string)
  end

end
