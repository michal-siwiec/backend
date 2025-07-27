# frozen_string_literal: true

module Queries
  module Orders
    class OrdersQuery < BaseQuery
      argument :input, Types::Custom::Inputs::Filtrations::Orders::OrdersInput, required: false
      type Types::Custom::Objects::Orders::OrderWithAllQuantityObject, null: false

      def resolve(params)
        response = OrderQuery.new(params).call

        {
          orders: response[:orders],
          all_orders_quantity: response[:quantity]
        }
      end
    end
  end
end
