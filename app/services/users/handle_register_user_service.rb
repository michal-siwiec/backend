module Users
  class HandleRegisterUserService < BaseService
    extend Utils::CallableObject

    def initialize(params:, session:)
      super()
      @params = params
      @session = session
    end

    def call
      user = register_user()
      send_registration_mail()
      login_user(user)
      user
    end

    private

    def register_user
      ::Users::RegisterUserService.call(email: @params[:email], password: @params[:password], avatars: @params[:avatars])
    end

    def send_registration_mail
      UserMailer.with(email: @params.fetch(:email), password: @params.fetch(:password)).account_registered.deliver_later
    end

    def login_user(user)
      ::Users::SessionUserService.new(user: user, session: @session).login
    end
  end
end
