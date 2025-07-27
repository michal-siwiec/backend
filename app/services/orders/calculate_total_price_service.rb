module Orders
  class CalculateTotalPriceService
    extend Utils::CallableObject

    def initialize(order:)
      @order = load_order(order: order)
    end

    def call
      products_price = calculate_products_price
      delivery_price = calculate_delivery_price

      (products_price + delivery_price).round(2)
    end

    private

    def load_order(order:)
      Order.preload(products_orders: [:product]).find(order.id)
    end

    def calculate_products_price
      @order.products_orders.map { |product_order| product_order.product_quantity * product_order.product.price }.sum.round(2)
    end

    def calculate_delivery_price
      Order::DELIVERIES_DETAILS.find { |delivery_details| delivery_details.fetch(:method) == @order.delivery_method }.fetch(:price).round(2)
    end
  end
end
