module Users
  class HandleRegisterUserService < BaseService
    extend Utils::CallableObject

    RegistrationError = Class.new(Errors::CustomGraphqlError)

    def initialize(params:, session:)
      super()
      @params = params
      @session = session
    end

    def call
      user = create_user
      add_avatars(user: user)
      send_registration_mail
      login_user(user: user)
      user
    end

    private

    def create_user
      User.create!(@params.except(:avatars))
    rescue ActiveRecord::RecordInvalid => e
      raise RegistrationError.new(message: 'Email is already taken!', error_code: :EMAIL_ALREADY_TAKEN) if e.record.errors.any? { |err| err.attribute == :email && err.type == :taken }
      raise e
    end

    def add_avatars(user:)
      ::Users::AddAvatarsService.call(user: user, avatars: @params.fetch(:avatars))
    end

    def send_registration_mail
      UserMailer.with(email: @params.fetch(:email), password: @params.fetch(:password)).account_registered.deliver_later
    end

    def login_user(user:)
      ::Users::SessionUserService.new(user: user, session: @session).login
    end
  end
end
