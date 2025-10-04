module Graphql
  class PrepareContextService
    extend Utils::CallableObject

    def initialize(params:, session:)
      @params = params
      @session = session
    end

    def call
      variables = prepare_variables
      query = @params.fetch(:query)
      operation_name = @params.fetch(:operationName, nil)
      context = { session: @session, current_user: current_user }

      { variables: variables, query: query, operation_name: operation_name, context: context }
    end

    private

    def prepare_variables
      variables_to_process = @params[:variables]

      case variables_to_process
      when String
        if variables_to_process.present?
          JSON.parse(variables_to_process) || {}
        else
          {}
        end
      when Hash
        variables_to_process
      when ActionController::Parameters
        variables_to_process.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
      when nil
        {}
      else
        raise ArgumentError, "Unexpected parameter: #{variables_to_process}"
      end
    end

    def current_user
      ::Session::UserSessionService.new(session: @session).current_user
    end
  end
end
