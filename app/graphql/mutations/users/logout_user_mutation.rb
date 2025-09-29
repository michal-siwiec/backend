# frozen_string_literal: true

module Mutations
  module Users
    class LogoutUserMutation < Mutations::BaseMutation
      argument :input, Types::Custom::Inputs::Mutations::Users::LogoutUserInput, required: true
      type Types::Custom::Objects::Users::UserObject

      def resolve(params)
        super(params)
        @session[:user_token] = nil
        User.find_by(@params)
      end
    end
  end
end
