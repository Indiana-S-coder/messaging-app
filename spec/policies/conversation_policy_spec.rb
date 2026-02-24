require 'rails_helper'

RSpec.describe ConversationPolicy do
  let!(:user1) { create(:user)}
  let!(:user2) { create(:user)}
  let!(:conversation) { create(:conversation)}

  describe '#show?' do
    context 'when user is part of the conversation' do
      let(:participant) { create(:conversation_participant, conversation: conversation, user: user1) }
      before do
        participant
      end

      it 'returns true' do
        policy = ConversationPolicy.new(user1, conversation)

        expect(policy.show?).to be true
      end
    end

    context 'when user is NOT part of the conversation' do
      before do
        create(:conversation_participant, conversation: conversation, user: user2)
      end

      it 'return false' do
        policy = ConversationPolicy.new(user1, conversation)
        expect(policy.show?).to be false
      end
    end

    context 'when conversation has no participants' do
      it 'returns false' do
        policy = ConversationPolicy.new(user1, conversation)

        expect(policy.show?).to be false
      end
    end
  end
end
