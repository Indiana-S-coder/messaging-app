class Api::V1::MessagesController < ApplicationController
  def create
    conversation = Conversation.find(params[:conversation_id])
    user = User.find(params[:user_id])

    unless conversation.users.exists?(user.id)
      return render json: { error: "User not part of this conversation"}, status: :forbidden
    end
    message = conversation.messages.create!(
      content: params[:content],
      user: user,
    )

    render json: message, status: :created
  end
end
