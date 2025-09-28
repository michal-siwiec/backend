module Users
  class RegisterUserService
    extend Utils::CallableObject

    RegistrationError = Class.new(Errors::CustomGraphqlError)

    def initialize(email:, password:, avatars:)
      @email = email
      @password = password
      @avatars = avatars
    end

    def call
      ActiveRecord::Base.transaction do
        user = User.create!(email: @email, password: @password)
        return user if @avatars.empty?

        avatars_details = process_avatars(user)
        user.avatars = avatars_details
        user.save!
        user
      end
    rescue ActiveRecord::RecordInvalid => e
      raise RegistrationError.new(message: 'Email is already taken!', error_code: :EMAIL_ALREADY_TAKEN) if e.record.errors.any? { |err| err.attribute == :email && err.type == :taken }
      raise e
    rescue ::Users::UploadAvatarsService::AvatarValidationError => e
      raise e
    end

    private

    def process_avatars(user)
      ::Users::UploadAvatarsService.call(avatars: @avatars, user_id: user.id)
    end
  end
end
