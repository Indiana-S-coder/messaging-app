module ResponseWrapper
  extend ActiveSupport::Concern

  def paginate(data, paginate_params:, resource: nil, status: :ok, resource_params: {}, extra_data: {})
    limit = paginate_params[:limit]&.to_i || 10
    before_id = paginate_params[:before_id]

    records = data
    records = records.where('id < ?', before_id) if before_id.present?
    records = records.limit(limit)

    # Convert to array to handle serialization and next cursor calculation
    records_array = records.to_a

    list = if records_array.present?
             if resource.nil?
               records_array
             else
               records_array.map do |record|
                 serializer = if resource_params.present?
                                resource.new(record, params: resource_params)
                              else
                                resource.new(record)
                              end

                 serializer.respond_to?(:serializable_hash) ? serializer.serializable_hash : serializer.as_json
               end
             end
           else
             []
           end

    next_cursor = records_array.last&.id

    {
      json: {
        list: list,
        next_cursor: next_cursor,
        limit: limit
      }.merge(extra_data),
      status: status
    }
  end

  module ClassMethods
    def paginate(data, paginate_params:, resource: nil, status: :ok, resource_params: {}, extra_data: {})
      # For class level access, we need a way to call the instance method
      # or just implement it here. Let's just implement it here for simplicity.
      limit = paginate_params[:limit]&.to_i || 10
      before_id = paginate_params[:before_id]

      records = data
      records = records.where('id < ?', before_id) if before_id.present?
      records = records.limit(limit)

      records_array = records.to_a

      list = if records_array.present?
               if resource.nil?
                 records_array
               else
                 records_array.map do |record|
                   serializer = if resource_params.present?
                                  resource.new(record, params: resource_params)
                                else
                                  resource.new(record)
                                end

                   serializer.respond_to?(:serializable_hash) ? serializer.serializable_hash : serializer.as_json
                 end
               end
             else
               []
             end

      next_cursor = records_array.last&.id

      {
        json: {
          list: list,
          next_cursor: next_cursor,
          limit: limit
        }.merge(extra_data),
        status: status
      }
    end
  end
end
