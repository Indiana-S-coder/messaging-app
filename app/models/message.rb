class Message < ApplicationRecord
  default_scope { order(created_at: :asc) }

  belongs_to :user
  belongs_to :conversation

  validates :content, presence: true
end
