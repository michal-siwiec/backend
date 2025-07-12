# frozen_string_literal: true

module Types
  module Custom
    module Inputs
      module Mutations
        module Opinions
          class OpinionInput < Types::BaseInputObject
            graphql_name 'OpinionMutationInput'
            argument :content, String, required: true
            argument :mark, Integer, required: true
            argument :user_id, ID, required: true
          end
        end
      end
    end
  end
end
