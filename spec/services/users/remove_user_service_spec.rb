require 'rails_helper'

describe Users::RemoveUserService, type: :service do
  describe '#call' do
    subject { described_class.call(user_id: user.id, session: session) }

    let(:user) { create(:user, email: 'test@example.com') }
    let(:session) { {} }
    let(:s3_service) { instance_double(Services::Aws::S3Service) }
    let(:session_service) { instance_double(Session::UserSessionService) }

    before do
      allow(Services::Aws::S3Service).to receive(:new).and_return(s3_service)
      allow(s3_service).to receive(:delete_object)
      allow(s3_service).to receive(:list_objects).and_return(OpenStruct.new(contents: []))
      allow(Session::UserSessionService).to receive(:new).and_return(session_service)
      allow(session_service).to receive(:destroy)
    end

    context 'when user removal is successful' do
      let(:newsletter) { create(:newsletter, email: user.email) }
      let(:s3_objects) do
        [
          instance_double('S3Object', key: "users/#{user.id}/avatars/avatar1.jpg"),
          instance_double('S3Object', key: "users/#{user.id}/avatars/avatar2.jpg")
        ]
      end

      before do
        newsletter
        allow(s3_service).to receive(:list_objects).and_return(instance_double('S3Response', contents: s3_objects))
      end

      it 'removes user from database' do
        expect(User.count).to eq(1)
        subject
        expect(User.count).to eq(0)
      end

      it 'unsubscribes user from newsletter' do
        expect(Newsletter.count).to eq(1)
        subject
        expect(Newsletter.count).to eq(0)
      end

      it 'deletes all user storage objects' do
        expect(Services::Aws::S3Service).to receive(:new).and_return(s3_service)
        expect(s3_service).to receive(:list_objects).with(directory_name: "users/#{user.id}")
        expect(s3_service).to receive(:delete_object).with(key: "users/#{user.id}/avatars/avatar1.jpg")
        expect(s3_service).to receive(:delete_object).with(key: "users/#{user.id}/avatars/avatar2.jpg")

        subject
      end

      it 'destroys user session' do
        expect(session_service).to receive(:destroy)
        subject
      end

      it 'returns the user' do
        expect(subject).to eq(user)
      end
    end

    context 'when S3 service fails' do
      let(:newsletter) { create(:newsletter, email: user.email) }

      before do
        newsletter
        allow(s3_service).to receive(:list_objects).and_raise(StandardError.new('S3 error'))
      end

      it 'rolls back transaction and does not remove user' do
        expect { subject rescue nil }.not_to change(User, :count)
      end

      it 'rolls back transaction and does not unsubscribe from newsletter' do
        expect { subject rescue nil }.not_to change(Newsletter, :count)
      end

      it 'raises the S3 error' do
        expect { subject }.to raise_error(StandardError, 'S3 error')
      end
    end
  end
end