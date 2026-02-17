class Api::V1::ConversationsController < ApplicationController
  def create
    user_ids = params[:user_ids]

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
    conversation = Conversation.find(params[:id])
    user = User.find(params[:user_id])

    unless ConversationParticipant.exists?(
            conversation_id: conversation.id,
            user_id: user.id
          )
      return render json: { error: "User not part of this conversation" }, status: :forbidden
    end

    messages= conversation.messages.order(created_at: :desc).limit(20).reverse

    render json: ConversationSerializer.new(conversation, messages: messages).as_json
  end

def index
  user = User.find(params[:user_id])
  conversations = user.conversations

  render json: conversations.map { |c|
{
  id: c.id,
  last_message: c.messages.order(created_at: :desc).first&.content
}}
end
end
