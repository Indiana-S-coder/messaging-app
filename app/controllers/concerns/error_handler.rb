module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError do |e|
      # ErrorNotifier.notify(e) # Assuming something like this exists or will be added
      render ResponseWrapper.parse("INTERNAL_ERROR", status: 500, message: e.message)
    end

    rescue_from ActiveRecord::RecordNotFound do |e|
      if e.model == "User"
        render ResponseWrapper.parse("UNAUTHORIZED", status: :unauthorized, message: "Invalid or expired token.")
      else
        render ResponseWrapper.parse("RECORD_NOT_FOUND", status: :not_found, message: e.message)
      end
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render ResponseWrapper.parse("RECORD_INVALID", status: :unprocessable_entity, message: e.record.errors.full_messages)
    end

    rescue_from TypeError do |e|
      render ResponseWrapper.parse("TYPE_ERROR", status: :unprocessable_entity, message: e.message)
    end
  end
end
