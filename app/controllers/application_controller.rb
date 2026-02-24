class ApplicationController < ActionController::API
  private

  def pagination_params
    {
      limit: params[:limit],
      cursor: params[:cursor].is_a?(Hash) || params[:cursor].is_a?(ActionController::Parameters) ? params.require(:cursor).permit(:before_time, :before_id) : nil
    }
  end
end
