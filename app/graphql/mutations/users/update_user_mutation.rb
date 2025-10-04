# frozen_string_literal: true

module Mutations
  module Users
    class UpdateUserMutation < Mutations::BaseMutation
      argument :input, Types::Custom::Inputs::Mutations::Users::UpdateUserInput, required: true
      type Types::Custom::Objects::Users::UserObject

      def resolve(params)
        super(params)

        user = User.find(@params.fetch(:user_id))
        user.update!(@params.except(:user_id))
        user
      end
    end
  end
end
