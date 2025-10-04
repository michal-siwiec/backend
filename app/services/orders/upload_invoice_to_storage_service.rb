module Orders
  class UploadInvoiceToStorageService
    extend Utils::CallableObject

    GeneratingInvoicePayloadError = Class.new(Errors::RollbarError)

    PATH_TO_INVOICE_TEMPLATE = 'app/views/invoice.html.erb'.freeze

    def initialize(order:)
      @order = order
    end

    def call
      invoice_payload = build_invoice_payload
      upload_on_storage(payload: invoice_payload)
    end

    private

    def build_invoice_payload
      {
        bucket: Rails.application.config.aws_bucket,
        path: "users/#{@order.user_id}/invoices/#{@order.id}.pdf",
        body: generate_invoice_in_base64
      }
    rescue StandardError
      raise GeneratingInvoicePayloadError.new(message: 'Generating invoice payload error', context_data: { order_id: @order.id })
    end

    def generate_invoice_in_base64
      presenter = OrderPresenter.new(@order)
      pdf_html = ActionController::Base.render(inline: File.read(PATH_TO_INVOICE_TEMPLATE), locals: { presenter: presenter })
      WickedPdf.new.pdf_from_string(pdf_html)
    end

    def upload_on_storage(payload:)
      ::Services::Aws::S3Service.new.put_object(key: payload.fetch(:path), body: payload.fetch(:body))
    end
  end
end
