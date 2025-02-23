module Errors
  class CustomGraphqlError < StandardError
    attr_reader :error_code, :message

    def initialize(message:, error_code:)
      @message = message
      @error_code = error_code
      super(message)
    end
  end
end
