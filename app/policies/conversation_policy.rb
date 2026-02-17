class ConversationPolicy
  def initializer(user, conversation)
    @user = user
    @conversation = conversation
  end

  def show?
    ConversationParticipant.exists?(
      conversation_id: @conversation.id,
      user_id: @user.id
    )
  end
end
