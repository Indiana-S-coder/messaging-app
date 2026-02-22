class ConversationSerializer
  def initialize(conversation, messages:)
    @conversation = conversation
    @messages = messages
  end

  def as_json
    {
      id: @conversation.id,
      participants: participants,
      messages: serialized_messages
    }
  end

  private

  def participants
    @conversation.users.map do |u|
      {
        id: u.id,
        email: u.email
      }
    end
  end

  def serialized_messages
    @messages.map do |m|
      m.is_a?(Hash) ? m : MessageSerializer.new(m).as_json
    end
  end
end
