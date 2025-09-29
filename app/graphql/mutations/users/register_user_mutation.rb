# frozen_string_literal: true

module Mutations
  module Users
    class RegisterUserMutation < Mutations::BaseMutation
      argument :input, Types::Custom::Inputs::Mutations::Users::RegisterUserInput, required: true
      type Types::Custom::Objects::Users::UserObject

      def resolve(params)
        super(params)
        ::Users::RegisterUserService.call(params: @params, session: context.fetch(:session))
      end
    end
  end
end
