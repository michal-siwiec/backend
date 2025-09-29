# frozen_string_literal: true

module Mutations
  module Users
    class LoginUserMutation < Mutations::BaseMutation
      argument :input, Types::Custom::Inputs::Mutations::Users::LoginUserInput, required: true
      type Types::Custom::Objects::Users::UserObject

      def resolve(params)
        super(params)
        ::Users::LoginUserService.call(params: @params, session: context.fetch(:session))
      end
    end
  end
end
