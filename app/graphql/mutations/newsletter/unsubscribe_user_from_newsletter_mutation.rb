# frozen_string_literal: true

module Mutations
  module Newsletter
    class UnsubscribeUserFromNewsletterMutation < GraphQL::Schema::Mutation
      argument :email, String, required: true
      type Types::Custom::Objects::Users::UserObject

      def resolve(params)
        Newsletter.find_by(email: params.fetch(:email))&.destroy!
      end
    end
  end
end
