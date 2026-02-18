class Api::V1::ConversationsController < ApplicationController
  before_action :set_conversation, only: [:show]
  before_action :set_user, only: [:show, :index]

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
    policy = ConversationPolicy.new(@user, @conversation)

    unless policy.show?
      return render json: { error: "User not part of this conversation" }, status: :forbidden
    end

    messages= @conversation.messages.order(created_at: :desc).limit(20).reverse

    render json: ConversationSerializer.new(@conversation, messages: messages).as_json
  end

def index
  conversations = @user.conversations.includes(:messages)

  render json: conversations.map { |c|
{
  id: c.id,
  last_message: c.messages.order(created_at: :desc).first&.content
}}
end
end

private

def set_conversation
  @conversation = Conversation.find(params[:id])
end

def set_user
  @user = User.find(params[:user_id])
end
