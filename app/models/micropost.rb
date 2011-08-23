class Micropost < ActiveRecord::Base
  attr_accessible :content

  belongs_to :user

  validates :content, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  default_scope :order => 'microposts.created_at DESC'

  scope :from_users_followed_by, lambda { |user| followed_by(user)}

  def replying?()
    replying_to = self.content.match(/@([\w+\-.]+)/)
    unless replying_to.nil? 
      target = User.find_by_name(replying_to[1])
      unless target.nil?
        self.in_reply_to = target.id
        self.save
      end
    end
  end

  private

  def self.followed_by(user)
    following_ids = %(SELECT followed_id FROM relationships 
WHERE follower_id = :user_id)
    where("((in_reply_to IS NULL OR in_reply_to = :user_id ) AND user_id IN (#{following_ids})) OR user_id = :user_id", 
          { :user_id => user })
  end
  
end
