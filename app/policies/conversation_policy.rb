class ConversationPolicy
  def initialize(user, conversation)
    @user = user
    @conversation = conversation
  end

  def show?
    participant?
  end

  def create?
    participant?
  end

  private

  def participant?
    ConversationParticipant.exists?(
      conversation_id: @conversation.id,
      user_id: @user.id
    )
  end
end
