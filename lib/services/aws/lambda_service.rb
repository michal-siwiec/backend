module Services
  module Aws
    class LambdaService
      extend Utils::CallableObject

      PerformingLambdaFunctionError = Class.new(Errors::RollbarError)

      def initialize(function_name:, invocation_type: 'RequestResponse', log_type: 'Tail', payload: {})
        @function_name = function_name
        @invocation_type = invocation_type
        @log_type = log_type
        @payload = payload
        @client = ::Aws::Lambda::Client.new({ region: Rails.application.config.aws_region,
                                              credentials: ::Aws::Credentials.new(ENV.fetch('AWS_ACCESS_KEY_ID'), ENV.fetch('AWS_SECRET_ACCESS_KEY')) })
      end

      def call
        response = @client.invoke({ function_name: @function_name,
                                    invocation_type: @invocation_type,
                                    log_type: @log_type,
                                    payload: @payload.to_json })

        logs = Base64.decode64(response.log_result)
        body_response = JSON.parse(response.payload.read)
        raise StandardError.new({ logs: logs, body_response: body_response }) if response.function_error.present?

        { logs: logs, body_response: body_response }
      rescue StandardError => e
        raise PerformingLambdaFunctionError.new(message: e, context_data: { function_name: @function_name,
                                                                            invocation_type: @invocation_type,
                                                                            log_type: @log_type,
                                                                            payload: @payload.to_json })
      end
    end
  end
end
