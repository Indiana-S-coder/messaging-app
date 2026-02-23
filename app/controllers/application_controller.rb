class ApplicationController < ActionController::API
  include ResponseWrapper

  before_action :authorize_request


  private

  def authorize_request
    header = request.headers['Authorization']
    token = header.split(' ').last if header

    decoded = JsonWebToken.decode(token)

    @current_user = User.find(decoded[:user_id]) if decoded
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

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
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
