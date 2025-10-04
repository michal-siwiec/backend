# frozen_string_literal: true

module Mutations
  module Newsletter
    class SubscribeUserToNewsletterMutation < BaseMutation
      argument :input, Types::Custom::Inputs::Mutations::Newsletter::SubscribeUserToNewsletterInput, required: true
      type Types::Custom::Objects::Users::UserObject

      def resolve(params)
        super(params)
        ::Newsletter.create!(email: @params.fetch(:email), name: @params.fetch(:name), surname: @params.fetch(:surname))
      end
    end
  end
end
