module Mails
  module Order
    class GenerateAtachmentsForOrderCreatedService
      extend Utils::CallableObject

      def initialize(order:)
        @order = order
      end

      def call
        attachments = []
        attachments << { file_name: 'Faktura.pdf', content: invoice }
        attachments
      end

      private

      def invoice
        invoice_key = "users/#{@order.user.id}/invoices/#{@order.id}.pdf"
        object = ::Services::Aws::S3Service.new.get_object(key: invoice_key)
        object.body.string
      end
    end
  end
end
