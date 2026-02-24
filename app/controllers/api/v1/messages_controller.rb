class Api::V1::MessagesController < ApplicationController
  before_action :set_conversation, only: [:create]
  after_action :update_conversation_last_message

  def create
    policy = ConversationPolicy.new(@current_user, @conversation)


    unless policy.show?
      return render ResponseWrapper.parse("FORBIDDEN", status: :forbidden, message: "User not part of this conversation")
    end

    @message = @conversation.messages.create!(
      content: params[:content],
      user: @current_user,
    )

    render ResponseWrapper.parse(MessageSerializer.new(@message).as_json, status: :created)
  end

  private

  def update_conversation_last_message
    return unless @message

    @conversation.touch
  end

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

end
