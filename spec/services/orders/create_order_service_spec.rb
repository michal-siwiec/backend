require 'rails_helper'

describe Orders::CreateOrderService, type: :service do
  describe '#call' do
    subject { described_class.call(params: params) }

    let(:user) { create(:user) }
    let(:product) { create(:product, available_quantity: 10) }
    let(:product2) { create(:product, available_quantity: 5) }
    let(:params) do
      {
        name: 'John',
        surname: 'Doe',
        phone_number: '123456789',
        street: 'Main Street',
        city: 'Warsaw',
        postal_code: '00-001',
        delivery_method: 'in_post',
        payment_method: 'cash_payment',
        email: 'john.doe@example.com',
        user: user,
        products_order: [
          {
            product_id: product.id,
            product_quantity: 3
          }
        ]
      }
    end

    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(Invoices::UploadOnStorageService).to receive(:call).and_return(true)
      allow(OrderMailer).to receive(:with).and_return(OrderMailer)
      allow(OrderMailer).to receive(:order_created).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later).and_return(true)
    end

    context 'when order is created successfully' do
      it 'creates new order' do
        expect { subject }.to change { Order.count }.from(0).to(1)
      end

      it 'creates products_orders' do
        expect { subject }.to change { ProductsOrder.count }.from(0).to(1)
      end

      it 'updates product available quantity' do
        expect { subject }.to change { product.reload.available_quantity }.from(10).to(7)
      end

      it 'uploads invoice to storage' do
        expect(Invoices::UploadOnStorageService).to receive(:call).with(order: instance_of(Order))
        subject
      end

      it 'sends order created email' do
        expect(OrderMailer).to receive(:with).with(order: instance_of(Order))
        expect(OrderMailer).to receive(:order_created)
        expect(message_delivery).to receive(:deliver_later).with(queue: :order)
        subject
      end

      it 'returns created order' do
        result = subject
        expect(result).to be_an_instance_of(Order)
        expect(result.name).to eq('John')
        expect(result.surname).to eq('Doe')
        expect(result.email).to eq('john.doe@example.com')
      end

      it 'associates products with order' do
        result = subject
        expect(result.products_orders.count).to eq(1)
        expect(result.products_orders.first.product).to eq(product)
        expect(result.products_orders.first.product_quantity).to eq(3)
      end
    end

    context 'when order creation fails' do
      before { params[:phone_number] = 'invalid'}

      it 'raises validation error' do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not create order' do
        expect { subject rescue nil }.not_to change { Order.count }
      end

      it 'does not create products_orders' do
        expect { subject rescue nil }.not_to change { ProductsOrder.count }
      end

      it 'does not update product quantity' do
        expect { subject rescue nil }.not_to change { product.reload.available_quantity }
      end

      it 'does not upload invoice' do
        expect(Invoices::UploadOnStorageService).not_to receive(:call)
        subject rescue nil
      end

      it 'does not send email' do
        expect(OrderMailer).not_to receive(:with)
        subject rescue nil
      end
    end

    context 'when upload service fails' do
      before { allow(Invoices::UploadOnStorageService).to receive(:call).and_raise(StandardError, 'Upload failed') }

      it 'raises error' do
        expect { subject }.to raise_error(StandardError, 'Upload failed')
      end

      it 'order is still created' do
        expect { subject rescue nil }.to change { Order.count }.from(0).to(1)
      end

      it 'product quantity is still updated' do
        expect { subject rescue nil }.to change { product.reload.available_quantity }.from(10).to(7)
      end
    end
  end
end
