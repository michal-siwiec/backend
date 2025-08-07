module Services
  module Aws
    class S3Service
      def initialize(bucket: Rails.configuration.aws_bucket)
        @bucket = bucket
        @client = ::Aws::S3::Client.new({ region: Rails.application.config.aws_region,
                                          credentials: ::Aws::Credentials.new(ENV.fetch('AWS_ACCESS_KEY_ID'), ENV.fetch('AWS_SECRET_ACCESS_KEY')) })
      end

      def get_object(key:)
        @client.get_object(bucket: @bucket, key: key)
      end

      def list_objects(directory_name:)
        @client.list_objects(bucket: @bucket, prefix: directory_name)
      end

      def put_object(key:, body:)
        @client.put_object(bucket: @bucket, key: key, body: body)
      end

      def delete_object(key:)
        @client.delete_object(bucket: @bucket, key: key)
      end
    end
  end
end
