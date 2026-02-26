module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authorize_request, only: [:login, :register]

      def register
        form = RegisterForm.new(user_params)
        user = form.save
        token = JsonWebToken.encode(user_id: user.id)

        render ResponseWrapper.parse(
          "RECORD_CREATE_SUCCESS",
          status: :created,
          data: {
            token: token,
            user: { id: user.id, email: user.email }
          },
          record: "User"
        )
      end

      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = JsonWebToken.encode(user_id: user.id)
          render ResponseWrapper.parse(
            "LOGIN_SUCCESS",
            data: {
              token: token,
              user: { id: user.id, email: user.email }
            }
          )
        else
          render ResponseWrapper.parse("AUTH_FAILURE", status: :unauthorized)
        end
      end

      private

      def user_params
        params.permit(:email, :password, :password_confirmation)
      end
    end
  end
end
