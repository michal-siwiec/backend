describe Users::HandleRegisterUserService, type: :service do
  describe '#call' do
    subject { described_class.call(params: params, session: session) }

    let(:params) do
      {
        email: 'test@example.com',
        password: 'password123',
        avatars: [{ file_name: 'avatar.jpg', base64: 'base64_data' }]
      }
    end
    let(:session) { {} }
    let(:user) { instance_double(User) }
    let(:session_user_service) { instance_double(Users::SessionUserService) }
    let(:mailer_instance) { instance_double(UserMailer) }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(Users::RegisterUserService).to receive(:call).and_return(user)
      allow(Users::SessionUserService).to receive(:new).and_return(session_user_service)
      allow(session_user_service).to receive(:login)
      allow(UserMailer).to receive(:with).and_return(mailer_instance)
      allow(mailer_instance).to receive(:account_registered).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
    end

    context 'when all services succeed' do
      it 'calls RegisterUserService with correct parameters' do
        expect(Users::RegisterUserService).to receive(:call).with(
          email: params[:email], 
          password: params[:password], 
          avatars: params[:avatars]
        )

        subject
      end

      it 'sends registration email with correct parameters' do
        expect(UserMailer).to receive(:with).with(email: params[:email], password: params[:password])
        expect(mailer_instance).to receive(:account_registered)
        expect(message_delivery).to receive(:deliver_later)

        subject
      end

      it 'logs in the user' do
        expect(Users::SessionUserService).to receive(:new).with(user: user, session: session)
        expect(session_user_service).to receive(:login)

        subject
      end

      it 'returns the created user' do
        expect(subject).to eq(user)
      end

      it 'executes steps in correct order' do
        expect(Users::RegisterUserService).to receive(:call).ordered
        expect(UserMailer).to receive(:with).ordered
        expect(Users::SessionUserService).to receive(:new).ordered
        expect(session_user_service).to receive(:login).ordered

        subject
      end
    end

    context 'when RegisterUserService fails' do
      let(:registration_error) do
        Users::RegisterUserService::RegistrationError.new(message: 'Email already taken',  error_code: :EMAIL_ALREADY_TAKEN)
      end

      before do
        allow(Users::RegisterUserService).to receive(:call).and_raise(registration_error)
      end

      it 'propagates the registration error' do
        expect { subject }.to raise_error(Users::RegisterUserService::RegistrationError) do |error|
          expect(error.message).to eq('Email already taken')
          expect(error.error_code).to eq(:EMAIL_ALREADY_TAKEN)
        end
      end

      it 'does not send email' do
        expect(UserMailer).not_to receive(:with)
        expect { subject }.to raise_error(Users::RegisterUserService::RegistrationError)
      end

      it 'does not login user' do
        expect(Users::SessionUserService).not_to receive(:new)
        expect { subject }.to raise_error(Users::RegisterUserService::RegistrationError)
      end
    end

    context 'when email sending fails' do
      before do
        allow(UserMailer).to receive(:with).and_raise(StandardError.new('Email service unavailable'))
      end

      it 'propagates the email error' do
        expect { subject }.to raise_error(StandardError, 'Email service unavailable')
      end

      it 'does not login user' do
        expect(Users::SessionUserService).not_to receive(:new)
        expect { subject }.to raise_error(StandardError)
      end
    end

    context 'when session login fails' do
      before do
        allow(session_user_service).to receive(:login).and_raise(StandardError.new('Session creation failed'))
      end

      it 'propagates the session error' do
        expect { subject }.to raise_error(StandardError, 'Session creation failed')
      end

      it 'still sends the registration email' do
        expect(UserMailer).to receive(:with)
        expect { subject }.to raise_error(StandardError)
      end
    end
  end
end
