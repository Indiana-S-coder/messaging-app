class User < ApplicationRecord
  has_secure_password
  has_many :conversation_participants
  has_many :conversations, through: :conversation_participants
  has_many :messages
end
