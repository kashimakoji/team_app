class Team < ApplicationRecord
  include FriendlyId
  friendly_id :name

  validates :name, presence: true, uniqueness: true

  belongs_to :owner, class_name: 'User', foreign_key: :owner_id
  has_many :assigns, dependent: :destroy
  has_many :members, through: :assigns, source: :user
  has_many :articles, dependent: :destroy
  has_many :agendas, dependent: :destroy
  has_many :users, foreign_key: :keep_team_id
  mount_uploader :icon, ImageUploader

  # before_update :isOwned?(current_user)

  def invite_member(user)
    assigns.create(user: user)
  end

  # def isOwned?(user)
  #   return false if user.nil?
  #   return self.user_id == user.id
  # end

end
