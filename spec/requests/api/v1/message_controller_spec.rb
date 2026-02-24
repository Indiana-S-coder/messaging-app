require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :request do
  let!(:user1) {create(:user)}
  let!(:user2) {create(:user)}
  let!(:conversation) {create(:conversation)}
  let(:token) { JsonWebToken.encode(user_id: user1.id) }
  let(:headers) { { "Authorization" => "Bearer #{token}" } }

  before do
    create(:conversation_participant, conversation: conversation, user: user1)
    create(:conversation_participant, conversation: conversation, user: user2)
  end

  describe '#create' do
    context 'when user is part of conversation' do
      it 'creates a message and returns 201' do
        expect {
          post "/api/v1/messages",
               params: { conversation_id: conversation.id, content: "Hello World!" },
               headers: headers
      }.to change(Message, :count).by(1)

      expect(response).to have_http_status(:created)

      json = JSON.parse(response.body)

      expect(json["content"]).to eq("Hello World!")
      expect(json["sender_id"]).to eq(user1.id)
      end

      it 'updates conversation updated_at timestamp' do
        old_updated_at = conversation.updated_at

        sleep 1 # ensure timestamp difference

        post "/api/v1/messages",
             params: { conversation_id: conversation.id, content: "Hello World updated." },
             headers: headers

        conversation.reload

        expect(conversation.updated_at).to be > old_updated_at
      end
    end

    context 'when user is not part of conversation' do
      let!(:stranger) {create(:user)}
      let(:stranger_token) { JsonWebToken.encode(user_id: stranger.id) }
      let(:stranger_headers) { { "Authorization" => "Bearer #{stranger_token}" } }

      it 'returns 403 forbidden' do
        expect {
          post "/api/v1/messages",
               params: { conversation_id: conversation.id, content: "not allowed" },
               headers: stranger_headers
       }.not_to change(Message, :count)

       expect(response).to have_http_status(:forbidden)

       json = JSON.parse(response.body)

       expect(json["error"]).to eq("User not part of this conversation")
      end
    end
  end
end
