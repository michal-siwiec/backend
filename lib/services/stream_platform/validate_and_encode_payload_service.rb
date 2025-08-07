require 'avro_turf/messaging'

module Services
  module StreamPlatform
    class ValidateAndEncodePayloadService
      extend Utils::CallableObject

      SchemaNotFoundError = Class.new(Errors::RollbarError)
      PayloadNotValidError = Class.new(Errors::RollbarError)

      def initialize(payload:, schema_name:)
        super()
        @payload = payload
        @schema_name = schema_name
        @avro = AvroTurf::Messaging.new(registry_url: Rails.application.config.schema_registry_url)
      end

      def call(version: 1, validate: true)
        @avro.encode(@payload, subject: @schema_name, version: version, validate: validate)
      rescue AvroTurf::SchemaNotFoundError => e
        raise SchemaNotFoundError.new(message: e.message, context_data: { schema_name: @schema_name, version: version })
      rescue Avro::SchemaValidator::ValidationError => e
        raise PayloadNotValidError.new(message: e.message, context_data: { payload: @payload, schema_name: @schema_name, version: version })
      end
    end
  end
end
