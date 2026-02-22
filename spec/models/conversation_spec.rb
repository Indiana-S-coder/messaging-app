require 'rails_helper'

RSpec.describe Conversation, type: :model do
  describe 'associations' do
    it { should have_many(:conversation_participants)}
    it {should have_many(:users).through(:conversation_participants)}
    it {should have_many(:messages)}
    it {should have_one(:latest_message)}
  end

  describe 'latest_message' do
    it 'returns the most recent message' do
      conversation = create(:conversation)
      user = create(:user)

      older = create(:message, conversation: conversation, user: user, created_at: 2.days.ago)
      newer = create(:message, conversation: conversation, user: user, created_at: 1.day.ago)

      expect(conversation.latest_message).to eq(newer)
    end
  end
end
