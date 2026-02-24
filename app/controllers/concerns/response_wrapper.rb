module ResponseWrapper
  class << self
    # Parses a response template by ID and returns a formatted JSON response.
    #
    # @param id [String, Symbol] The identifier for the response template.
    # @param status [Symbol] The HTTP status to return (default: :ok).
    # @param data [Hash, Object] Additional data to include in the response (default: {}).
    # @param resource [Class] The resource class to use for serialization.
    # @param resource_params [Hash] Parameters to pass to the resource class.
    # @param message [String] Custom message to override the template.
    # @param args [Hash] Additional arguments for string interpolation in the response template.
    # @return [Hash] A hash containing the JSON response and HTTP status.
    def parse(id = 'SUCCESS', status: :ok, data: {}, message: nil, resource: nil, resource_params: {}, **args)
      response = find_response(id)

      return { json: {}, status: status } unless response || id == 'SUCCESS'

      data = serialize_data(data, resource, resource_params)

      return { json: data, status: status } if id == 'SUCCESS'

      {
        json: {
          title: response["title"] % args,
          message: message.presence || (response["message"] % args),
          helper: response["helper"] ? (response["helper"] % args) : nil,
          type: response["type"],
          data: data
        }.compact_blank.as_json,
        status: status
      }
    end

    # Paginates the given data and wraps the response in a standardized JSON structure.
    # Uses cursor-based pagination.
    #
    # @param data [ActiveRecord::Relation] The collection of records to paginate.
    # @param resource [Class] The resource class used to serialize the records.
    # @param paginate_params [Hash] The pagination parameters, expects :limit and :cursor keys.
    # @option paginate_params [Integer] :limit The number of items per page (defaults to 10).
    # @option paginate_params [Hash] :cursor Cursor info { before_time: ..., before_id: ... }.
    # @param status [Symbol] The HTTP status to return (defaults to :ok).
    # @param resource_params [Hash] Parameters to pass to the resource class.
    # @param extra_data [Hash] Additional data to merge into the response.
    #
    # @return [Hash] A hash containing the paginated JSON response and HTTP status.
    def paginate(data, paginate_params:, resource: nil, status: :ok, resource_params: {}, extra_data: {})
      limit = paginate_params[:limit]&.to_i || 10
      cursor = paginate_params[:cursor]

      records = data
      if cursor.present?
        before_time = cursor[:before_time]
        before_id = cursor[:before_id]

        if before_time.present? && before_id.present?
          records = records.where("created_at < ? OR (created_at = ? AND id < ?)", before_time, before_time, before_id)
        elsif before_time.present?
          records = records.where("created_at < ?", before_time)
        end
      end

      records_array = records.limit(limit).to_a

      list = serialize_data(records_array, resource, resource_params)

      last_record = records_array.last

      pagination_meta = {
        cursor: last_record ? {
          before_time: last_record.created_at,
          before_id: last_record.id
        } : nil,
        limit: limit
      }

      {
        json: {
          list: list,
          total: data.count
        }.merge(pagination_meta).merge(extra_data),
        status: status
      }
    end

    private

    def serialize_data(data, resource, resource_params)
      return data unless resource && data.present?

      if data.respond_to?(:to_ary)
        data.map { |record| resource.new(record, params: resource_params).serializable_hash }
      else
        resource.new(data, params: resource_params).serializable_hash
      end
    end

    def find_response(id)
      responses[id.to_s] || generalized_response(id)
    end

    def generalized_response(id)
      return unless id.to_s.include?("_")

      generalized_id = id.to_s.sub(/\A[^_]+/, "RECORD")
      responses[generalized_id]
    end

    def responses
      @responses ||= Utility.load_yaml("config/responses.yaml")
    end
  end
end
