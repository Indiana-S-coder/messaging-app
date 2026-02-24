require 'rails_helper'

RSpec.describe Api::V1::ConversationsController, type: :request do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }
    let(:token1) { JsonWebToken.encode(user_id: user1.id) }
    let(:headers1) { { "Authorization" => "Bearer #{token1}" } }

    describe '#index' do
      context 'when conversations exist' do
        let!(:conversation) {create(:conversation)}

        before do
          create(:conversation_participant, conversation: conversation, user: user1)
          create(:conversation_participant, conversation: conversation, user: user2)

          create(:message, conversation:conversation, user: user1, content: "Last message")
        end

        it 'returns list conversations with last message' do
          get "/api/v1/conversations", headers: headers1

          expect(response).to have_http_status(:ok)

          json = JSON.parse(response.body)

          expect(json["list"].length).to eq(1)
          expect(json["list"].first["id"]).to eq(conversation.id)
          expect(json["list"].first["last_message"]).to eq("Last message")
        end
      end

      context 'when no conversations exist' do
        it 'returns empty list when no conversations exist' do

          get "/api/v1/conversations", headers: headers1

          json = JSON.parse(response.body)

          expect(json["list"]).to eq([])
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
        get "/api/v1/conversations/#{conversation.id}", headers: headers1
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["messages"]).to be_present
        expect(json["next_cursor"]).to be_present
        expect(json["limit"]).to be_present
      end

      it 'returns forbidden if user is not part of conversation' do
        stranger = create(:user)
        stranger_token = JsonWebToken.encode(user_id: stranger.id)
        get "/api/v1/conversations/#{conversation.id}", headers: { "Authorization" => "Bearer #{stranger_token}" }
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("User not part of this conversation")
      end
    end

    describe '#create' do
      it 'create a new conversation when none exists' do
        post "/api/v1/conversations", params: {user_ids: [user2.id]}, headers: headers1
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["id"]).to be_present
        expect(json["participants"].length).to eq(2)
      end

      it 'returns existing conversation if already present' do
        conversation = create(:conversation)
        create(:conversation_participant, conversation: conversation, user: user1)
        create(:conversation_participant, conversation: conversation, user: user2)
        post "/api/v1/conversations", params: {user_ids: [user2.id]}, headers: headers1
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["id"]).to eq(conversation.id)
      end
    end
end
