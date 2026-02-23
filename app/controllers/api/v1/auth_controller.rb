module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authorize_request, only: [:login, :register]
    
      def register
        user = User.create!(user_params)
        token = JsonWebToken.encode(user_id: user.id)
      
        render json: { token: token }, status: :created
      end
    
      def login
        user = User.find_by(email: params[:email])
      
        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          render json: { token: token }
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end
    
      private
    
      def user_params
        params.permit(:email, :password, :password_confirmation)
      end
    end
  end
end
