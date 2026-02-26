class Api::V1::MessageCreateForm
  include ActiveModel::Model

  attr_accessor :content, :conversation, :current_user

  validates :content, presence: true

  def save
    @message = conversation.messages.create!(
      content: content,
      user: current_user
    )
  end

  def message
    @message
  end

  def errors_response
    ResponseWrapper.parse(
      errors.full_messages.to_sentence,
      status: :unprocessable_entity,
      message: errors.full_messages.to_sentence
    )
  end
end
