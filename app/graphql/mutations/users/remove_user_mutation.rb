# frozen_string_literal: true

module Mutations
  module Users
    class RemoveUserMutation < GraphQL::Schema::Mutation
      argument :user_id, ID, required: true
      type Types::Custom::Objects::Users::UserObject

      def resolve(params)
        ::Users::RemoveUserService.call(user_id: params.fetch(:user_id), session: context.fetch(:session))
      end
    end
  end
end
