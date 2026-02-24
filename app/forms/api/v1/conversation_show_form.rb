class Api::V1::ConversationShowForm
  include ActiveModel::Model

  attr_accessor :user_id, :conversation_id

  validates :user_id, :conversation_id, presence: true
  validate :user_exists
  validate :conversation_exists
  validate :authorized, if: -> { user && conversation }

  def user
    @user ||= User.find_by(id: user_id)
  end

  def conversation
    @conversation ||= Conversation.find_by(id: conversation_id)
  end

  def error_status
    return :not_found if user.nil? || conversation.nil?
    return :forbidden unless authorized?
    nil
  end

  private

  def user_exists
    errors.add(:user, "not found") if user.nil?
  end

  def conversation_exists
    errors.add(:conversation, "not found") if conversation.nil?
  end

  def authorized?
    ConversationPolicy.new(user, conversation).show?
  end

  def authorized
    unless authorized?
      errors.add(:base, "User not part of this conversation")
    end
  end
end
