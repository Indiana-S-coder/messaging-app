class Api::V1::ConversationCreateForm
  include ActiveModel::Model

  attr_accessor :user_ids, :current_user

  validates :user_ids, presence: true
  validate :users_exist

  def save
    @conversation = find_existing_conversation || create_new_conversation
  end

  def conversation
    @conversation
  end

  def errors_response
    ResponseWrapper.parse(
      errors.full_messages.to_sentence,
      status: :unprocessable_entity,
      message: errors.full_messages.to_sentence
    )
  end

  private

  def normalized_user_ids
    @normalized_user_ids ||= (Array.wrap(user_ids).map(&:to_i) | [current_user.id]).sort
  end

  def users_exist
    return if user_ids.blank?

    found_users_count = User.where(id: user_ids).count
    if found_users_count != Array.wrap(user_ids).uniq.count
      errors.add(:user_ids, "one or more users not found")
    end
  end

  def find_existing_conversation
    return nil unless normalized_user_ids.length == 2

    Conversation.joins(:conversation_participants)
                .where(conversation_participants: { user_id: normalized_user_ids })
                .group("conversations.id")
                .having("COUNT(conversation_participants.user_id) = 2")
                .first
  end

  def create_new_conversation
    Conversation.transaction do
      conversation = Conversation.create!
      normalized_user_ids.each do |u_id|
        ConversationParticipant.create!(
          user_id: u_id,
          conversation: conversation
        )
      end
      conversation
    end
  end
end
