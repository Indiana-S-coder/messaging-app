class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: { case_sensitive: false }

  has_many :conversation_participants
  has_many :conversations, through: :conversation_participants
  has_many :messages
end
