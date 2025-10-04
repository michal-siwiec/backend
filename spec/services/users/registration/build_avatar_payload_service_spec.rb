describe Users::Registration::BuildAvatarPayloadService, type: :builder do
  describe  '#build' do
    subject { described_class.call(user_id: user.id, avatar: avatar) }

    let(:user) { create(:user, id: '18c9bb53-3d92-4e8d-944c-660ddb5a2228') }
    let(:avatar) { { base64: 'abcd,efgh', file_name: 'file_name', main: true } }

    it { expect(subject.fetch(:base64).force_encoding('ASCII-8BIT')).to eq("y\xF8!".force_encoding('ASCII-8BIT')) }
    it { expect(subject.fetch(:path)).to eq('users/18c9bb53-3d92-4e8d-944c-660ddb5a2228/avatars/file_name') }
    it { expect(subject.fetch(:details)).to eq({ main: true, key: 'users/18c9bb53-3d92-4e8d-944c-660ddb5a2228/avatars/file_name', bucket: 'budoman-development' }) }
  end
end
