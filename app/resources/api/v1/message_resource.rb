class Api::V1::MessageResource
  def initialize(message, params: {})
    @message = message
    @params = params
  end

  def serializable_hash
    {
      id: @message.id,
      content: @message.content,
      sender_id: @message.user_id,
      created_at: @message.created_at
    }
  end
end
