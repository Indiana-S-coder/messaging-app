require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, type: :request do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    describe '#index' do
      context 'when conversations exist' do
        let!(:conversation) {create(:conversation)}

        before do
          create(:conversation_participant, conversation: conversation, user: user1)
          create(:conversation_participant, conversation: conversation, user: user2)

          create(:message, conversation:conversation, user: user1, content: "Last message")
        end

        it 'returns list conversations with last message' do
          get "/api/v1/conversations", params: { user_id: user1.id}

          expect(response).to have_http_status(:ok)

          json = JSON.parse(response.body)
          data = json["data"]

          expect(data["list"].length).to eq(1)
          expect(data["list"].first["id"]).to eq(conversation.id)
          expect(data["list"].first["last_message"]).to eq("Last message")
        end
      end

      context 'when no conversations exist' do
        it 'returns empty list when no conversations exist' do

          get "/api/v1/conversations", params: {user_id: user1.id}

          json = JSON.parse(response.body)
          data = json["data"]

          expect(data["list"]).to eq([])
        end
      end
    end

    describe '#show' do
      let!(:conversation) { create(:conversation)}

      before do
        create(:conversation_participant, conversation: conversation, user: user1)
        create(:conversation_participant, conversation: conversation, user: user2)

        create_list(:message, 3, conversation: conversation, user: user1)
      end

      it 'returns conversation messages with metadata' do
        get "/api/v1/conversations/#{conversation.id}", params: { user_id: user1.id }
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        data = json["data"]
        expect(data["messages"]).to be_present
        expect(json["next_cursor"]).to be_present
        expect(json["limit"]).to be_present
      end

      it 'returns forbidden if user is not part of conversation' do
        stranger = create(:user)
        get "/api/v1/conversations/#{conversation.id}", params: { user_id: stranger.id }
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["error"]["code"]).to eq("FORBIDDEN")
        expect(json["error"]["message"]).to eq("User not part of this conversation")
      end
    end

    describe '#create' do
      it 'create a new conversation when none exists' do
        post "/api/v1/conversations", params: {user_ids: [user1.id, user2.id]}
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        data = json["data"]
        expect(data["id"]).to be_present
        expect(data["participants"].length).to eq(2)
      end

      it 'returns existing conversation if already present' do
        conversation = create(:conversation)
        create(:conversation_participant, conversation: conversation, user: user1)
        create(:conversation_participant, conversation: conversation, user: user2)
        post "/api/v1/conversations", params: {user_ids: [user1.id, user2.id]}
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        data = json["data"]
        expect(data["id"]).to eq(conversation.id)
      end
    end
end
