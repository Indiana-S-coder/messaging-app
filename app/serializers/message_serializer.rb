class MessageSerializer
  def initialize(message)
    @message = message
  end

  def as_json
    {
      id: @message.id,
      content: @message.content,
      sender_id: @message.user_id,
      created_at: @message.created_at
    }
  end
end
