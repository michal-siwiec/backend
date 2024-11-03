# frozen_string_literal: true

module Types
  module Custom
    module Objects
      module Users
        class AvatarObject < Types::BaseObject
          field :bucket, String, null: false
          field :key, String, null: false
          field :main, String, null: false
        end
      end
    end
  end
end
