# frozen_string_literal: true

module Mutations
  module Opinions
    class AddOpinionMutation < BaseMutation
      argument :input, Types::Custom::Inputs::Mutations::Opinions::OpinionInput, required: true
      type Types::Custom::Objects::Opinions::OpinionObject

      def resolve(params)
        super(params)
        user = ::Session::UserSessionService.new(session: context.fetch(:session)).current_user
        raise ActiveRecord::RecordNotFound, 'User not found' unless user

        Opinion.create!(content: @params.fetch(:content), mark: @params.fetch(:mark), user_id: user.id)
      end
    end
  end
end
