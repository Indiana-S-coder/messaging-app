class Api::V1::ConversationsController < ApplicationController
  def create
    user_ids = params[:user_ids]

    if user_ids.length == 2
      existing_conversation = Conversation.joins(:conversation_participants).where(conversation_participants: {user_id: user_ids}).group("conversations.id").having("COUNT(conversation_participants.user_id) = 2").first

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
      participants: conversation.users.map {|u|
        {id: u.id, email: u.email}
      }
    }, status: :created
  end

  def show
    conversation = Conversation.find(params[:id])

    render json: {
      id: conversation.id,
      participants: conversation.users.map { |u|
      {
        id: u.id,
        email: u.email
      }
    },
    messages: conversation.messages.order(created_at: :asc).map {|m|
    {
      id: m.id,
      content: m.content,
      sender_id: m.user_id,
      created_at: m.created_at
    }
  }
}
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
