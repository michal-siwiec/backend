# frozen_string_literal: true

module Types
  module Custom
    module Inputs
      module Mutations
        module Users
          class LoginUserInput < Types::BaseInputObject
            argument :email, String, required: true
            argument :password, String, required: true
          end
        end
      end
    end
  end
end
