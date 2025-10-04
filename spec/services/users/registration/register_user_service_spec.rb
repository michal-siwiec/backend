require 'rails_helper'

describe Users::Registration::RegisterUserService, type: :service do
  describe '#call' do
    subject { described_class.call(params: params, session: session) }

    let(:params) do
      {
        email: 'test@example.com',
        password: 'password123',
        avatars: []
      }
    end
    let(:session) { {} }
    let(:user) { instance_double(User) }
    let(:session_user_service) { instance_double(Users::SessionUserService) }
    let(:mailer_instance) { instance_double(UserMailer) }
    let(:message_delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(Users::SessionUserService).to receive(:new).and_return(session_user_service)
      allow(session_user_service).to receive(:login)
      allow(UserMailer).to receive(:with).and_return(mailer_instance)
      allow(mailer_instance).to receive(:account_registered).and_return(message_delivery)
      allow(message_delivery).to receive(:deliver_later)
    end

    context 'when user registration is successful' do
      context 'without avatars' do
        it 'creates user successfully' do
          expect(User.count).to eq(0)
          
          user = subject
          
          expect(User.count).to eq(1)
          expect(user).to be_a(User)
          expect(user.email).to eq(params[:email])
          expect(user.avatars).to be_empty
        end

        it 'sends registration email with correct parameters' do
          expect(UserMailer).to receive(:with).with(email: params[:email], password: params[:password])
          expect(mailer_instance).to receive(:account_registered)
          expect(message_delivery).to receive(:deliver_later)

          subject
        end

        it 'logs in the user' do
          expect(Users::SessionUserService).to receive(:new).with(user: kind_of(User), session: session)
          expect(session_user_service).to receive(:login)

          subject
        end
      end

      context 'with valid avatars' do
        let(:params) do
          {
            email: 'test@example.com',
            password: 'password123',
            avatars: [{ main: true, base64: 'base64_data', file_name: 'avatar1.jpg', file_type: 'image/jpeg' }]
          }
        end

        let(:avatars_details) do
          [{ 'main' => 'true', 'bucket' => 'budoman-development', 'key' => 'users/71f02bc6-1827-4650-851b-00e105c180de/avatars/valid avatar.jpeg' }]
        end

        before do
          allow(Users::Registration::ProcessAvatarsService).to receive(:call).and_return(avatars_details)
        end

        it 'creates user with avatars' do
          expect(User.count).to eq(0)
          
          user = subject
          
          expect(User.count).to eq(1)
          expect(user).to be_a(User)
          expect(user.email).to eq(params[:email])
          expect(user.avatars).to eq(avatars_details)
        end

        it 'calls ProcessAvatarsService with correct parameters' do
          expect(Users::Registration::ProcessAvatarsService).to receive(:call).with(avatars: params[:avatars], user_id: kind_of(String))

          subject
        end
      end
    end

    context 'when user registration fails' do
      context 'with duplicate email' do
        before { create(:user, email: params[:email]) }

        it 'raises RegistrationError with EMAIL_ALREADY_TAKEN' do
          expect { subject }.to raise_error(Users::Registration::RegisterUserService::RegistrationError) do |error|
            expect(error.message).to eq('Email is already taken!')
            expect(error.error_code).to eq(:EMAIL_ALREADY_TAKEN)
          end
        end

        it 'does not create user' do
          expect { subject rescue nil }.not_to change(User, :count)
        end

        it 'does not send email' do
          expect(UserMailer).not_to receive(:with)
          expect { subject }.to raise_error(Users::Registration::RegisterUserService::RegistrationError)
        end

        it 'does not login user' do
          expect(Users::SessionUserService).not_to receive(:new)
          expect { subject }.to raise_error(Users::Registration::RegisterUserService::RegistrationError)
        end
      end

      context 'with invalid email format' do
        let(:params) do
          {
            email: 'invalid-email',
            password: 'password123',
            avatars: []
          }
        end

        it 'raises ActiveRecord::RecordInvalid' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'does not create user' do
          expect { subject rescue nil }.not_to change(User, :count)
        end
      end

      context 'with avatar validation error' do
        let(:params) do
          {
            email: 'test@example.com',
            password: 'password123',
            avatars: [{ main: true, base64: 'base64_data', file_name: 'avatar1.jpg', file_type: 'image/jpeg' }]
          }
        end

        before do
          allow(Users::Registration::ProcessAvatarsService).to receive(:call).and_raise(Users::Registration::ProcessAvatarsService::AvatarValidationError.new(
            message: 'Avatar is not valid!',
            error_code: :AVATAR_NOT_VALID
          ))
        end

        it 'raises AvatarValidationError' do
          expect { subject }.to raise_error(Users::Registration::ProcessAvatarsService::AvatarValidationError) do |error|
            expect(error.message).to eq('Avatar is not valid!')
            expect(error.error_code).to eq(:AVATAR_NOT_VALID)
          end
        end

        it 'does not create user due to transaction rollback' do
          expect { subject rescue nil }.not_to change(User, :count)
        end
      end
    end
  end
end
