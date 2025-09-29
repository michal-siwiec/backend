require 'rails_helper'

describe Users::LoginUserService, type: :service do
  describe '#call' do
    subject { described_class.call(params: params, session: session) }

    let(:params) { { email: 'test@example.com', password: 'password123' } }
    let(:user) { create(:user, email: params[:email], password: params[:password]) }
    let(:session) { instance_double('Session') }
    let(:session_user_service) { instance_double(Users::SessionUserService) }

    before do
      allow(Users::SessionUserService).to receive(:new).and_return(session_user_service)
      allow(session_user_service).to receive(:login).and_return(true)
    end

    context 'when login is successful' do
      before { user }

      it 'logs in the user' do
        expect(Users::SessionUserService).to receive(:new).with(user: user, session: session)
        expect(session_user_service).to receive(:login)
        subject
      end

      it 'returns the user' do
        expect(subject).to eq(user)
      end
    end

    context 'when user does not exist' do
      it 'raises AuthenticationError with USER_NOT_FOUND' do
        expect { subject }.to raise_error(Users::LoginUserService::AuthenticationError) do |error|
          expect(error.message).to eq("User with email: #{params[:email]} doesn't exist!")
          expect(error.error_code).to eq(:USER_NOT_FOUND)
        end
      end

      it 'does not call SessionUserService' do
        expect(Users::SessionUserService).not_to receive(:new)
        expect { subject }.to raise_error(Users::LoginUserService::AuthenticationError)
      end
    end

    context 'when password is incorrect' do
      let(:user) { create(:user, email: 'test@example.com', password: 'password123') }
      let(:params) { { email: 'test@example.com', password: 'wrong_password' } }

      before { user }

      it 'raises AuthenticationError with INVALID_CREDENTIALS' do
        expect { subject }.to raise_error(Users::LoginUserService::AuthenticationError) do |error|
          expect(error.message).to eq('Incorrect password!')
          expect(error.error_code).to eq(:INVALID_CREDENTIALS)
        end
      end

      it 'does not call SessionUserService' do
        expect(Users::SessionUserService).not_to receive(:new)
        expect { subject }.to raise_error(Users::LoginUserService::AuthenticationError)
      end
    end
  end
end
