module Orders
  class CreateOrderService
    extend Utils::CallableObject

    def initialize(params:)
      @order_params = params.except(:products_order)
      @order_products_params = params.fetch(:products_order)
    end

    def call
      order = create_order
      upload_invoice_to_storage(order: order)
      send_order_created_email(order: order)
      order
    end

    private

    def create_order
      ActiveRecord::Base.transaction do
        order = Order.new(@order_params)
        add_products_to_order(order: order)
        update_products_quantity(order: order)
        order.save!
        order
      end
    end

    def add_products_to_order(order:)
      @order_products_params.each { |params| order.products_orders << ProductsOrder.new(params) }
    end

    def update_products_quantity(order:)
      order.products_orders.each do |product_order|
        product = product_order.product
        ordered_quantity = product_order.product_quantity
        actual_quantity = product.available_quantity - ordered_quantity

        product.update!(available_quantity: actual_quantity)
      end
    end

    def upload_invoice_to_storage(order:)
      ::Invoices::UploadOnStorageService.call(order: order)
    end

    def send_order_created_email(order:)
      OrderMailer.with(order: order).order_created.deliver_later(queue: :order)
    end
  end
end
