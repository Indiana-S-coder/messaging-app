class ApplicationController < ActionController::API

  include ResponseWrapper
  include ErrorHandler

  before_action :authorize_request


  private

  def pagination_params
    {
      limit: params[:limit],
      cursor: params[:cursor].is_a?(Hash) || params[:cursor].is_a?(ActionController::Parameters) ? params.require(:cursor).permit(:before_time, :before_id) : nil
    }
  end

  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    decoded = JsonWebToken.decode(token)

    @current_user = User.find(decoded[:user_id]) if decoded

    render ResponseWrapper.parse("UNAUTHORIZED", status: :unauthorized) unless @current_user
  end

end
