class Api::V1::ConversationsController < ApplicationController
  def create
    user_ids = Array.wrap(params[:user_ids])
    user_ids |= @current_user.id

    if user_ids.length == 2
      existing_conversation = Conversation.joins(:conversation_participants).where(conversation_participants: { user_id: user_ids }).group("conversations.id").having("COUNT(conversation_participants.user_id) = 2").first

      if existing_conversation
        return render ResponseWrapper.parse(existing_conversation, status: :ok)
      end
    end

    conversation = Conversation.create!


    user_ids.each do |user_id|
      ConversationParticipant.create!(
        user_id: user_id,
        conversation: conversation
      )
    end

    render ResponseWrapper.parse({
      id: conversation.id,
      participants: conversation.users.map { |u|
        { id: u.id, email: u.email }
      }
    }, status: :created)
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
      resource: MessageSerializer,
      paginate_params: params
    )

    # Reconstruct the conversation data with the paginated messages
    conversation_data = ConversationSerializer.new(
      conversation,
      messages: pagination_response[:json][:data][:list]
    ).as_json

    # Render final response merging conversation data into the standardized structure
    render ResponseWrapper.parse(conversation_data, status: pagination_response[:status], extra_data: {
      next_cursor: pagination_response[:json][:next_cursor],
      limit: pagination_response[:json][:limit]
    })
  end

  def index
    conversations = @current_user.conversations.includes(:latest_message)

    data = conversations.map { |c|
      {
        id: c.id,
        last_message: c.latest_message&.content
      }
    }

    render ResponseWrapper.parse({ list: data }, status: :ok)
  end

  private

  def conversation_params
    params.permit(:user_id).merge(conversation_id: params[:id])
  end
end
