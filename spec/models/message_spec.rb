require 'rails_helper'

RSpec.describe Message, type: :model do
  describe 'associations' do
    it {should belong_to(:user)}
    it {should belong_to(:conversation)}
  end

  describe 'validations' do
    it {should validate_presence_of(:content)}
  end

  describe 'default scope' do
    let!(:conversation) { create(:conversation) }
    let!(:user) { create(:user) }
    it 'orders messages by created_at ascending' do

      older = create(:message, conversation: conversation, user: user, created_at: 2.days.ago)
      newer = create(:message, conversation: conversation, user: user, created_at: 1.day.ago)

      expect(Message.all).to eq([older, newer])
    end
  end
end
