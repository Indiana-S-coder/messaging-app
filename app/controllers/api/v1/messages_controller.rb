class Api::V1::MessagesController < ApplicationController
  before_action :set_conversation, only: [:create]
  before_action :set_user, only: [:create]

  def create
    policy = ConversationPolicy.new(@user, @conversation)


    unless policy.show?
      return render json: { error: "User not part of this conversation" }, status: :forbidden
    end
    message = @conversation.messages.create!(
      content: params[:content],
      user: @user,
    )

    render json: MessageSerializer.new(message).as_json, status: :created
  end


  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def set_user
    @user = User.find(params[:user_id])
  end
end
