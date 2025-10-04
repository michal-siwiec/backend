describe Users::Registration::UploadAvatarsService, type: :service do
  describe '#call' do
    subject { described_class.call(user_id: user_id, avatars: avatars) }

    let(:user_id) { '71f02bc6-1827-4650-851b-00e105c180de' }
    let(:avatars) do
      [
        { main: true, base64: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD', file_name: 'avatar1.jpg', file_type: 'image/jpeg' },
        { main: false, base64: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD', file_name: 'avatar2.jpg', file_type: 'image/jpeg' }
      ]
    end

    let(:s3_service) { instance_double(Services::Aws::S3Service) }
    let(:build_avatar_payload_service) { instance_double(Users::Registration::BuildAvatarPayloadService) }
    let(:validate_avatar_service) { instance_double(Users::Registration::ValidateAvatarService) }

    before do
      allow(Services::Aws::S3Service).to receive(:new).and_return(s3_service)
      allow(s3_service).to receive(:put_object)
      allow(Users::Registration::BuildAvatarPayloadService).to receive(:call).and_return(
        {
          base64: 'decoded_base64_1',
          path: 'users/71f02bc6-1827-4650-851b-00e105c180de/avatars/avatar1.jpg',
          details: { main: 'true', bucket: 'budoman-development', key: 'users/71f02bc6-1827-4650-851b-00e105c180de/avatars/avatar1.jpg' }
        },
        {
          base64: 'decoded_base64_2', 
          path: 'users/71f02bc6-1827-4650-851b-00e105c180de/avatars/avatar2.jpg',
          details: { main: 'false', bucket: 'budoman-development', key: 'users/71f02bc6-1827-4650-851b-00e105c180de/avatars/avatar2.jpg' }
        }
      )
      allow(Users::Registration::ValidateAvatarService).to receive(:call).and_return(true, true)
    end

    context 'when all avatars are valid' do
      it 'calls BuildAvatarPayloadService for each avatar' do
        expect(Users::Registration::BuildAvatarPayloadService).to receive(:call).with(user_id: user_id, avatar: avatars[0])
        expect(Users::Registration::BuildAvatarPayloadService).to receive(:call).with(user_id: user_id, avatar: avatars[1])

        subject
      end

      it 'validates each avatar' do
        expect(Users::Registration::ValidateAvatarService).to receive(:call).with(avatar_as_base64: 'decoded_base64_1')
        expect(Users::Registration::ValidateAvatarService).to receive(:call).with(avatar_as_base64: 'decoded_base64_2')

        subject
      end

      it 'uploads each avatar to S3' do
        expect(Services::Aws::S3Service).to receive(:new).twice.and_return(s3_service)
        expect(s3_service).to receive(:put_object).with(body: 'decoded_base64_1', key: 'users/71f02bc6-1827-4650-851b-00e105c180de/avatars/avatar1.jpg')
        expect(s3_service).to receive(:put_object).with(body: 'decoded_base64_2', key: 'users/71f02bc6-1827-4650-851b-00e105c180de/avatars/avatar2.jpg')

        subject
      end

      it 'returns avatars details' do
        expect(subject).to eq([
          { main: 'true', bucket: 'budoman-development', key: 'users/71f02bc6-1827-4650-851b-00e105c180de/avatars/avatar1.jpg' },
          { main: 'false', bucket: 'budoman-development', key: 'users/71f02bc6-1827-4650-851b-00e105c180de/avatars/avatar2.jpg' }
        ])
      end

      it 'processes avatars in correct order' do
        expect(Users::Registration::BuildAvatarPayloadService).to receive(:call).ordered
        expect(Users::Registration::ValidateAvatarService).to receive(:call).ordered
        expect(s3_service).to receive(:put_object).ordered
        expect(Users::Registration::BuildAvatarPayloadService).to receive(:call).ordered
        expect(Users::Registration::ValidateAvatarService).to receive(:call).ordered
        expect(s3_service).to receive(:put_object).ordered

        subject
      end
    end

    context 'when some avatars are invalid' do
      before do
        allow(Users::Registration::ValidateAvatarService).to receive(:call).and_return(true, false)
      end

      it 'raises AvatarValidationError for invalid avatar' do
        expect { subject }.to raise_error(Users::Registration::UploadAvatarsService::AvatarValidationError) do |error|
          expect(error.message).to eq('Avatar: avatar2.jpg is not valid! Has to present real face')
          expect(error.error_code).to eq(:AVATAR_NOT_VALID)
        end
      end

      it 'does not upload invalid avatar to storage' do
        expect(s3_service).to receive(:put_object).once
        expect { subject }.to raise_error(Users::Registration::UploadAvatarsService::AvatarValidationError)
      end
    end

    context 'when all avatars are invalid' do
      before do
        allow(Users::Registration::ValidateAvatarService).to receive(:call).and_return(false, false)
      end

      it 'raises AvatarValidationError for first invalid avatar' do
        expect { subject }.to raise_error(Users::Registration::UploadAvatarsService::AvatarValidationError) do |error|
          expect(error.message).to eq('Avatar: avatar1.jpg is not valid! Has to present real face')
          expect(error.error_code).to eq(:AVATAR_NOT_VALID)
        end
      end

      it 'does not upload any avatars to storage' do
        expect(s3_service).not_to receive(:put_object)
        expect { subject }.to raise_error(Users::Registration::UploadAvatarsService::AvatarValidationError)
      end
    end
  end
end
