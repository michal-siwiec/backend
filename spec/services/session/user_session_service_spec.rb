require 'rails_helper'

describe Session::UserSessionService, type: :service do
  describe '#current_user' do
    subject { service.current_user }

    let(:service) { described_class.new(session: session) }
    let(:user) { create(:user) }

    context 'when session has valid user token' do
      let(:session) { { user_token: 'valid-token' } }

      before do
        allow(JWT).to receive(:decode).with('valid-token', nil, false).and_return([user.id])
      end

      it 'returns the user' do
        expect(subject).to eq(user)
      end

      it 'decodes the JWT token' do
        expect(JWT).to receive(:decode).with('valid-token', nil, false)
        subject
      end
    end

    context 'when session has no user token' do
      let(:session) { {} }

      it 'returns nil' do
        expect(subject).to be_nil
      end

      it 'does not call JWT.decode' do
        expect(JWT).not_to receive(:decode)
        subject
      end
    end
  end

  describe '#login' do
    subject { service.login }

    let(:user) { create(:user) }
    let(:session) { {} }
    let(:service) { described_class.new(session: session, user: user) }

    context 'when user is provided' do
      before do
        allow(JWT).to receive(:encode).and_return('encoded-token')
      end

      it 'encodes user ID into JWT token' do
        expect(JWT).to receive(:encode).with(user.id, nil, 'none')
        subject
      end

      it 'stores token in session' do
        subject
        expect(session[:user_token]).to eq('encoded-token')
      end
    end

    context 'when user is not provided' do
      let(:service) { described_class.new(session: session) }

      it 'raises ArgumentError' do
        expect { subject }.to raise_error(ArgumentError, 'User is required for login')
      end

      it 'does not store anything in session' do
        expect { subject rescue nil }.not_to change { session }
      end
    end
  end

  describe '#logout' do
    subject { service.logout }

    let(:session) { { user_token: 'existing-token' } }
    let(:service) { described_class.new(session: session) }

    it 'sets user_token to nil in session' do
      expect { subject }.to change { session[:user_token] }.from('existing-token').to(nil)
    end
  end

  describe '#destroy' do
    subject { service.destroy }

    let(:session) { {} }
    let(:service) { described_class.new(session: session) }

    before do
      allow(session).to receive(:destroy)
    end

    it 'calls destroy on session' do
      expect(session).to receive(:destroy)
      subject
    end
  end
end
