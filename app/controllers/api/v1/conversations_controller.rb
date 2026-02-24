class Api::V1::ConversationsController < ApplicationController
  before_action :set_conversation, only: [:show]

  def create
    user_ids = Array.wrap(params[:user_ids])
    user_ids |= @current_user.id

    if user_ids.length == 2
      existing_conversation = Conversation.joins(:conversation_participants).where(conversation_participants: { user_id: user_ids }).group("conversations.id").having("COUNT(conversation_participants.user_id) = 2").first

      if existing_conversation
        return render ResponseWrapper.parse(data: existing_conversation, resource: Api::V1::ConversationResource, resource_params: { include_participants: true })
      end
    end

    conversation = Conversation.create!

    user_ids.each do |user_id|
      ConversationParticipant.create!(
        user_id: user_id,
        conversation: conversation
      )
    end

    render ResponseWrapper.parse('RECORD_CREATE_SUCCESS', status: :created, data: conversation, resource: Api::V1::ConversationResource, resource_params: { include_participants: true }, record: 'Conversation')
  end

  def show
    form = Api::V1::ConversationShowForm.new(conversation_params)

    unless form.valid?
      return render ResponseWrapper.parse(
        form.errors.full_messages.to_sentence,
        status: form.error_status,
        message: form.errors.full_messages.to_sentence
      )
    end

    conversation = form.conversation

    # Cursor pagination: Fetch messages descending by ID (most recent first)
    messages_relation = conversation.messages.reorder(id: :desc)

    # Use the ResponseWrapper to paginate messages.
    pagination_response = ResponseWrapper.paginate(
      messages_relation,
      resource: Api::V1::MessageResource,
      pagination_params:
    )

    # Wrap the conversation data and include paginated messages
    render ResponseWrapper.parse(
      data: conversation,
      resource: Api::V1::ConversationResource,
      resource_params: { include_participants: true },
      extra_data: { messages: pagination_response[:json] }
    )
  end

  def index
    conversations = @current_user.conversations.includes(:latest_message)

    render ResponseWrapper.paginate(
      conversations,
      resource: Api::V1::ConversationResource,
      pagination_params:
    )
  end

  private

def set_conversation
  @conversation = Conversation.find(params[:id])
end
  def conversation_params
    params.permit(:user_id).merge(conversation_id: params[:id])
  end
end
