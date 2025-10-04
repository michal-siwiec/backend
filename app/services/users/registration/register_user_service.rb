module Users
  module Registration
    class RegisterUserService
      extend Utils::CallableObject

      RegistrationError = Class.new(Errors::CustomGraphqlError)

      def initialize(params:, session:)
        @params = params
        @session = session
      end

      def call
        user = create_user_with_avatars()
        send_registration_mail()
        login_user(user)
        user
      end

      private

      def create_user_with_avatars
        ActiveRecord::Base.transaction do
          user = User.create!(email: @params[:email], password: @params[:password])
          return user if @params[:avatars].empty?

          avatars_details = process_avatars(user)
          user.avatars = avatars_details
          user.save!
          user
        end
      rescue ActiveRecord::RecordInvalid => e
        raise RegistrationError.new(message: 'Email is already taken!', error_code: :EMAIL_ALREADY_TAKEN) if e.record.errors.any? { |err| err.attribute == :email && err.type == :taken }
        raise e
      end

      def process_avatars(user)
        ::Users::Registration::ProcessAvatarsService.call(avatars: @params[:avatars], user_id: user.id)
      end

      def send_registration_mail
        UserMailer.with(email: @params.fetch(:email), password: @params.fetch(:password)).account_registered.deliver_later
      end

      def login_user(user)
        ::Session::UserSessionService.new(user: user, session: @session).login
      end
    end
  end
end
