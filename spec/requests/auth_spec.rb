require 'rails_helper'

RSpec.describe "Api::V1::AuthController", type: :request do
  describe "#register" do
    context 'when params are valid' do
      it 'creates a user and returns token' do
        expect {
          post "/api/v1/register", params: {
            email: "test@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        }.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)

        json = JSON.parse(response.body)

        expect(json["token"]).to be_present
        expect(json["user"]["email"]).to eq("test@example.com")
      end
    end

    context 'when params are invalid' do
      it 'returns validation errors' do
        post "/api/v1/register", params: {
          email: "",
          password: "123",
          password_confirmation: "456"
        }

        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "#login" do
    let!(:user) { create(:user, password: "Password1$") }

    context 'when credentials are correct' do
      it 'returns token and user data' do
        post "/api/v1/login", params: {
          email: user.email,
          password: "Password1$"
        }

        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)

        expect(json["token"]).to be_present
        expect(json["user"]["email"]).to eq(user.email)
      end
    end

    context 'when credentials are incorrect' do
      it 'returns unauthorized' do
        post "/api/v1/login", params: {
          email: user.email,
          password: "Password!$"
        }

        expect(response).to have_http_status(:unauthorized)

        json = JSON.parse(response.body)

        expect(json["error"]).to eq("Invalid credentials")
      end
    end

    context 'when user does not not exist' do
      it 'returns unauthorized' do
        post "/api/v1/login", params: {
          email: "unknown@email.com",
          password: "Password1$"
        }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
