class Api::V1::ConversationResource
  def initialize(conversation, params: {})
    @conversation = conversation
    @params = params
  end

  def serializable_hash
    {
      id: @conversation.id,
      last_message: @conversation.latest_message&.content,
      participants: participants
    }.compact
  end

  private

  def participants
    return unless @conversation.users.loaded? || @params[:include_participants]

    @conversation.users.map do |u|
      {
        id: u.id,
        email: u.email
      }
    end
  end
end
