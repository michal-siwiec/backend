# frozen_string_literal: true

module Session
  class UserSessionService
    JWT_PASSWORD = nil
    JWT_SIGNING = 'none'
    JWT_VALIDATION = false

    def initialize(session:, user: nil)
      @session = session
      @user = user
    end

    def current_user
      user_token = @session.fetch(:user_token, nil)
      return unless user_token

      user_id = JWT.decode(user_token, JWT_PASSWORD, JWT_VALIDATION).first
      User.find(user_id)
    end

    def login
      raise ArgumentError, 'User is required for login' unless @user

      user_token = JWT.encode(@user.id, JWT_PASSWORD, JWT_SIGNING)
      @session[:user_token] = user_token
    end

    def logout
      @session[:user_token] = nil
    end

    def destroy
      @session.destroy
    end
  end
end
