module Users
  module Registration
    class ValidateAvatarService
      extend Utils::CallableObject

      FUNCTION_LAMBDA_NAME = 'ValidateFaceInsideAvatar'.freeze
      LOG_FILE_NAME = 'validate_avatar_lambda_function.log'.freeze

      def initialize(avatar_as_base64:)
        @avatar_as_string = Base64.encode64(avatar_as_base64)
      end

      # TODO: Serwis nie działa poprawnie - brak uprawnień do Lambda-ki
      #? Czy nie powinienem chwytać PerformingLambdaFunctionError?
      def call
        response = ::Services::Aws::LambdaService.call(function_name: FUNCTION_LAMBDA_NAME, payload: { avatar_as_string: @avatar_as_string })
        is_avatar_valid = response.fetch(:body_response)
        is_avatar_valid
      rescue StandardError => e
        handle_error(error: e)
      end

      private

      def handle_error(error:)
        ::Services::LoggerService.new(file_name: LOG_FILE_NAME).error(message: "#{FUNCTION_LAMBDA_NAME} error occured!\n\
                                                                              Context: #{error&.rollbar_context&.except(:payload) || {}}\n\
                                                                              Error message: #{error.message}\n\
                                                                              Error backtrace:\n#{error.backtrace.first(3).join("\n")}\n")
        Rollbar.error(error)
        false
      end
    end
  end
end
