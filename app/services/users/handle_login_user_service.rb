module Users
  class HandleLoginUserService < BaseService
    AuthenticationError = Class.new(Errors::CustomGraphqlError)

    def initialize(params:, session:)
      super()
      @params = params
      @session = session
    end

    def call
      user = find_user!
      login_user(user: user)
      user
    end

    private

    def find_user!
      user = User.find_by(email: @params.fetch(:email))
      raise AuthenticationError.new(message: "User with email: #{@params.fetch(:email)} doesn't exist!", error_code: :USER_NOT_FOUND) unless user
      raise AuthenticationError.new(message: "Incorrect password!", error_code: :INVALID_CREDENTIALS) unless user.authenticate(@params.fetch(:password))

      user
    end

    def login_user(user:)
      ::Users::SessionUserService.new(user: user, session: @session).login
    end
  end
end
