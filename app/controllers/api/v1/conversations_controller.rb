class Api::V1::ConversationsController < ApplicationController
  before_action :set_conversation, only: [:show]
  before_action :set_policy, only: [:show]

  def create
    user_ids = Array.wrap(params[:user_ids])
    user_ids |= @current_user.id

    if user_ids.length == 2
      existing_conversation = Conversation.joins(:conversation_participants).where(conversation_participants: { user_id: user_ids }).group("conversations.id").having("COUNT(conversation_participants.user_id) = 2").first

      if existing_conversation
        return render json: existing_conversation, status: :ok
      end
    end

    conversation = Conversation.create!


    user_ids.each do |user_id|
      ConversationParticipant.create!(
        user_id: user_id,
        conversation: conversation
      )
    end

    render json: {
      id: conversation.id,
      participants: conversation.users.map { |u|
        { id: u.id, email: u.email }
      }
    }, status: :created
  end

  def show
    policy = ConversationPolicy.new(@current_user, @conversation)

    unless policy.show?
      return render json: { error: "User not part of this conversation" }, status: :forbidden
    end

    # Cursor pagination: Fetch messages descending by ID (most recent first)
    messages_relation = @conversation.messages.reorder(id: :desc)

    # Use the ResponseWrapper to paginate messages.
    # The list of messages will be in the :list key of the ResponseWrapper output.
    pagination_response = paginate(
      messages_relation,
      resource: MessageSerializer,
      paginate_params: params
    )

    # Reconstruct the conversation data with the paginated messages
    # We pass the paginated list to the serializer to maintain consistency
    conversation_data = ConversationSerializer.new(
      @conversation,
      messages: pagination_response[:json][:list]
    ).as_json

    # Render final response with pagination metadata merged into the conversation hash or at root
    render json: conversation_data.merge(
      next_cursor: pagination_response[:json][:next_cursor],
      limit: pagination_response[:json][:limit]
    ), status: pagination_response[:status]
  end

  def index
    conversations = @current_user.conversations.includes(:latest_message)

    data = conversations.map { |c|
      {
        id: c.id,
        last_message: c.latest_message&.content
      }
    }
    # For simplicity, returning the mapped list. Cursor pagination on arrays
    # needs specific handling in ResponseWrapper if desired.
    render json: { list: data }
  end
end

private

def set_conversation
  @conversation = Conversation.find(params[:id])
end

def set_policy
  @policy = ConversationPolicy.new(@user, @conversation)
end
