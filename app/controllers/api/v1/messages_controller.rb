class Api::V1::MessagesController < ApplicationController
  before_action only: :create do
    authorize conversation
  end

  after_action :update_conversation_last_message, only: :create

  def create
    form = Api::V1::MessageCreateForm.new(
      content: params[:content],
      conversation: conversation,
      current_user: @current_user
    )

    return render form.errors_response unless form.valid?

    @message = form.save

    render ResponseWrapper.parse(
      data: @message,
      resource: Api::V1::MessageResource
    )
  end

  private

  def update_conversation_last_message
    return unless @message

    conversation.touch
  end

  def conversation
    @conversation ||= Conversation.find(params[:conversation_id])
  end
end
