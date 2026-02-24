module ResponseWrapper
  module_function

  def parse(data_or_code, status: :ok, message: nil, extra_data: {})
    response_body = if status_success?(status)
                      { data: data_or_code }
                    else
                      {
                        error: {
                          code: data_or_code,
                          message: message
                        }
                      }
                    end

    {
      json: response_body.merge(extra_data),
      status: status
    }
  end

  def paginate(data, paginate_params:, resource: nil, status: :ok, resource_params: {}, extra_data: {})
    permitted_params = if paginate_params.respond_to?(:permit)
                         paginate_params.permit(:limit, :before_time, :before_id)
                       else
                         paginate_params.slice(:limit, :before_time, :before_id)
                       end

    limit = permitted_params[:limit]&.to_i || 10
    before_time = permitted_params[:before_time]
    before_id = permitted_params[:before_id]

    records = data
    if before_time.present? && before_id.present?
      records = records.where('created_at < ? OR (created_at = ? AND id < ?)', before_time, before_time, before_id)
    elsif before_time.present?
      records = records.where('created_at < ?', before_time)
    end

    records_array = records.limit(limit).to_a

    list = serialize_collection(records_array, resource, resource_params)
    last_record = records_array.last

    pagination_meta = {
      next_cursor: {
        before_time: last_record&.created_at,
        before_id: last_record&.id
      },
      limit: limit
    }

    parse({ list: list }, status: status, extra_data: pagination_meta.merge(extra_data))
  end

  def status_success?(status)
    case status
    when Symbol
      ![:bad_request, :unauthorized, :forbidden, :not_found, :method_not_allowed, :not_acceptable, :conflict, :unprocessable_entity, :internal_server_error].include?(status)
    when Integer
      status < 400
    else
      true
    end
  end

  def serialize_collection(collection, resource, resource_params)
    return [] if collection.blank?
    return collection if resource.nil?

    collection.map do |record|
      serializer = resource_params.present? ? resource.new(record, params: resource_params) : resource.new(record)
      serializer.respond_to?(:serializable_hash) ? serializer.serializable_hash : serializer.as_json
    end
  end
end
