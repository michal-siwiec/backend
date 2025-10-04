describe Orders::UploadInvoiceToStorageService, type: :service do
  describe '#call' do
    subject { described_class.call(order: order) }

    let(:order) do
      user = create(:user, id: 'b612c713-b328-43af-b8e2-c1704e68a463')
      create(:order, id: '552967ef-8ed8-4b2f-8088-4e0ed5347660', user: user)
    end

    let(:s3_service) { instance_double(Services::Aws::S3Service, put_object: true) }
    let(:wicked_pdf) { instance_double(WickedPdf, pdf_from_string: 'pdf_from_string') }

    before do
      allow(Services::Aws::S3Service).to receive(:new).and_return(s3_service)
      allow(WickedPdf).to receive(:new).and_return(wicked_pdf)
    end

    context 'when invoice generation and upload succeeds' do
      it 'uploads invoice to storage with correct parameters' do
        expected_path = 'users/b612c713-b328-43af-b8e2-c1704e68a463/invoices/552967ef-8ed8-4b2f-8088-4e0ed5347660.pdf'
        expect(s3_service).to receive(:put_object).once.with(key: expected_path, body: 'pdf_from_string')
        subject
      end
    end

    context 'when invoice generation fails' do
      before do
        allow(WickedPdf).to receive(:new).and_raise(StandardError, 'PDF generation failed')
      end

      it 'raises GeneratingInvoicePayloadError' do
        expect { subject }.to raise_error(Orders::UploadInvoiceToStorageService::GeneratingInvoicePayloadError)
      end
    end
  end
end
