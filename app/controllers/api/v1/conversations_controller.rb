class Api::V1::ConversationsController < ApplicationController
  def index
    conversations = @current_user.conversations.includes(:latest_message)

    render ResponseWrapper.paginate(
      conversations,
      resource: Api::V1::ConversationResource,
      pagination_params:
    )
  end

  def show
    conversation = Conversation.find(params[:id])
    authorize conversation

    render ResponseWrapper.parse(
      data: conversation,
      resource: Api::V1::ConversationResource,
      resource_params: { include_participants: true, include_messages: true }
    )
  end

  def create
    form = Api::V1::ConversationCreateForm.new(user_ids: params[:user_ids], current_user: @current_user)

    return render form.errors_response unless form.valid?

    form.save

    render ResponseWrapper.parse('RECORD_CREATE_SUCCESS', status: :created, data: form.conversation, resource: Api::V1::ConversationResource, resource_params: { include_participants: true }, record: 'Conversation')
  end
end
