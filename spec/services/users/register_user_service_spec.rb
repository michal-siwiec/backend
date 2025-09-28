require 'rails_helper'

describe Users::RegisterUserService, type: :service do
  describe '#call' do
    subject { described_class.call(email: email, password: password, avatars: avatars) }

    let(:email) { 'test@example.com' }
    let(:password) { 'password123' }
    let(:avatars) { [] }

    context 'when user registration is successful' do
      context 'without avatars' do
        it 'creates user successfully' do
          expect(User.count).to eq(0)
          
          user = subject

          expect(user).to be_a(User)
          expect(user.email).to eq(email)
          expect(user.avatars).to be_empty
        end
      end

      context 'with valid avatars' do
        let(:avatars) { [{ main: true, base64: 'base64_data', file_name: 'avatar1.jpg', file_type: 'image/jpeg' }] }
        let(:upload_avatars_service) { instance_double(Users::UploadAvatarsService) }
        let(:avatars_details) do
          [{ 'main' => 'true', 'bucket' => 'budoman-development', 'key' => 'users/71f02bc6-1827-4650-851b-00e105c180de/avatars/valid avatar.jpeg' }]
        end

        before do
          allow(Users::UploadAvatarsService).to receive(:call).and_return(avatars_details)
        end

        it 'creates user with avatars' do
          expect(User.count).to eq(0)
          
          user = subject

          expect(user).to be_a(User)
          expect(user.email).to eq(email)
          expect(user.avatars).to eq(avatars_details)
        end

        it 'calls UploadAvatarsService with correct parameters' do
          expect(Users::UploadAvatarsService).to receive(:call).with(avatars: avatars, user_id: kind_of(String))

          subject
        end
      end
    end

    context 'when user registration fails' do
      context 'with duplicate email' do
        before { create(:user, email: email) }

        it 'raises RegistrationError with EMAIL_ALREADY_TAKEN' do
          expect { subject }.to raise_error(Users::RegisterUserService::RegistrationError) do |error|
            expect(error.message).to eq('Email is already taken!')
            expect(error.error_code).to eq(:EMAIL_ALREADY_TAKEN)
          end
        end

        it 'does not create user' do
          expect { subject rescue nil }.not_to change(User, :count)
        end
      end

      context 'with invalid email format' do
        let(:email) { 'invalid-email' }

        it 'raises ActiveRecord::RecordInvalid' do
          expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
        end

        it 'does not create user' do
          expect { subject rescue nil }.not_to change(User, :count)
        end
      end

      context 'with avatar validation error' do
        let(:avatars) { [{ main: true, base64: 'base64_data', file_name: 'avatar1.jpg', file_type: 'image/jpeg' }] }

        before do
          allow(Users::UploadAvatarsService).to receive(:call).and_raise(Users::UploadAvatarsService::AvatarValidationError.new(
            message: 'Avatar is not valid!',
            error_code: :AVATAR_NOT_VALID
          ))
        end

        it 'raises AvatarValidationError' do
          expect { subject }.to raise_error(Users::UploadAvatarsService::AvatarValidationError) do |error|
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
