module Mails
  module Newsletter
    class GenerateAtachmentsForSendNewsletterService
      extend Utils::CallableObject

      def call
        attachments = []
        attachments << { file_name: 'Prezentacja budowlana.pptx', content: construction_presentation }
        attachments
      end

      private

      def construction_presentation
        construction_presentation_key = 'documents/prezentacja-budowlana.pptx'
        object = ::Services::Aws::S3Service.new.get_object(key: construction_presentation_key)
        object.body.string
      end
    end
  end
end
