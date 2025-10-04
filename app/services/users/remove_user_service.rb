module Users
  class RemoveUserService
    extend Utils::CallableObject

    def initialize(user_id:, session:)
      super()
      @user = User.find(user_id)
      @session = session
    end

    def call
      ActiveRecord::Base.transaction do
        unsubscribe_user_from_newsletter
        clean_user_storage_objects
        destroy_user_session
        destroy_user
        @user
      end
    end

    private

    def unsubscribe_user_from_newsletter
      Newsletter.find_by(email: @user.email)&.destroy!
    end

    def clean_user_storage_objects
      s3_service = ::Services::Aws::S3Service.new
      directory_name = "users/#{@user.id}"
      user_objects = s3_service.list_objects(directory_name: directory_name).contents

      user_objects.each { |object| s3_service.delete_object(key: object.key) }
    end

    def destroy_user_session
      ::Session::UserSessionService.new(session: @session).destroy
    end

    def destroy_user
      @user.destroy!
    end
  end
end
