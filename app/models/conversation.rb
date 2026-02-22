class Conversation < ApplicationRecord
  has_many :conversation_participants
  has_many :users, through: :conversation_participants
  has_many :messages
  has_one :latest_message, -> { order(created_at: :desc) }, class_name: "Message"
end
