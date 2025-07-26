# frozen_string_literal: true

class OrderQuery
  def initialize(params)
    @params = params.fetch(:input).to_h
    @orders = Order.all
  end

  def call
    filter_by_membership_to_user_if_need
    total_quantity = @orders.count
    paginate
    sort_by_creation_date
    { orders: @orders, quantity: total_quantity }
  end

  private

  def filter_by_membership_to_user_if_need
    return unless @params.fetch(:user_id)

    @orders = User.find(@params.fetch(:user_id)).orders
  end

  def paginate
    page = @params.dig(:pagination, :page)
    quantity_per_page = @params.dig(:pagination, :quantity_per_page)

    @orders = @orders.limit(quantity_per_page).offset(page * quantity_per_page)
  end

  def sort_by_creation_date
    @orders.sort_by(&:created_at).reverse
  end
end
