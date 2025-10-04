module Users
  module Registration
    class UploadAvatarsService
      extend Utils::CallableObject

      AvatarValidationError = Class.new(Errors::CustomGraphqlError)

      def initialize(avatars:, user_id:)
        @avatars = avatars
        @user_id = user_id
      end

      def call
        avatars_details = [];

        @avatars.each do |avatar|
          payload = build_avatar_payload(avatar: avatar)
          is_avatar_valid = validate_avatar(avatar_as_base64: payload[:base64])
          raise AvatarValidationError.new(message: "Avatar: #{avatar[:file_name]} is not valid! Has to present real face", error_code: :AVATAR_NOT_VALID) unless is_avatar_valid

          upload_avatar_to_storage(payload: payload)
          avatars_details << payload.fetch(:details)
        end

        avatars_details
      end

      private

      def build_avatar_payload(avatar:)
        ::Users::Registration::BuildAvatarPayloadService.call(user_id: @user_id, avatar: avatar)
      end

      def validate_avatar(avatar_as_base64:)
        ::Users::Registration::ValidateAvatarService.call(avatar_as_base64: avatar_as_base64)
      end

      def upload_avatar_to_storage(payload:)
        ::Services::Aws::S3Service.new.put_object(body: payload.fetch(:base64), key: payload.fetch(:path))
      end
    end
  end
end
