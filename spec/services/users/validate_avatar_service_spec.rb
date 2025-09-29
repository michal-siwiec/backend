require 'rails_helper'

describe Users::ValidateAvatarService, type: :service do
  describe '#call' do
    subject { described_class.call(avatar_as_base64: avatar_as_base64) }

    let(:avatar_as_base64) { 'decoded_base64_image_data' }
    let(:logger_service) { instance_double(Services::LoggerService) }

    before do
      allow(Services::Aws::LambdaService).to receive(:call).and_return(lambda_response)
      allow(Services::LoggerService).to receive(:new).and_return(logger_service)
      allow(logger_service).to receive(:error)
      allow(Rollbar).to receive(:error)
    end

    let(:lambda_response) { { body_response: true } }

    context 'when Lambda detects a face in avatar' do
      it 'calls Lambda service with correct parameters' do
        expect(Services::Aws::LambdaService).to receive(:call).with(function_name: 'ValidateFaceInsideAvatar', payload: { avatar_as_string: Base64.encode64(avatar_as_base64) })

        subject
      end

      it 'returns true when face is detected' do
        expect(subject).to be true
      end
    end

    context 'when Lambda does not detect a face in avatar' do
      let(:lambda_response) { { body_response: false } }

      it 'calls Lambda service with correct parameters' do
        expect(Services::Aws::LambdaService).to receive(:call).with(function_name: 'ValidateFaceInsideAvatar', payload: { avatar_as_string: Base64.encode64(avatar_as_base64) })

        subject
      end

      it 'returns false when no face is detected' do
        expect(subject).to be false
      end
    end

    context 'when Lambda service raises an error' do
      let(:error) { StandardError.new('Lambda function failed') }

      before do
        allow(Services::Aws::LambdaService).to receive(:call).and_raise(error)
        allow(error).to receive(:rollbar_context).and_return({ payload: 'test', user_id: 123 })
        allow(error).to receive(:message).and_return('Lambda function failed')
        allow(error).to receive(:backtrace).and_return(['line1', 'line2', 'line3'])
      end

      it 'logs error to file with correct filename' do
        expect(Services::LoggerService).to receive(:new).with(file_name: 'validate_avatar_lambda_function.log')
        expect(logger_service).to receive(:error).with(message: include('ValidateFaceInsideAvatar error occured!'))

        subject
      end

      it 'logs error to Rollbar' do
        expect(Rollbar).to receive(:error).with(error)
        subject
      end

      it 'returns false on error' do
        expect(subject).to be false
      end

      it 'includes error context in log message (excluding payload)' do
        expect(logger_service).to receive(:error).with(message: include('Context: {:user_id=>123}'))
        subject
      end

      it 'includes error message in log' do
        expect(logger_service).to receive(:error).with(message: include('Error message: Lambda function failed'))
        subject
      end

      it 'includes backtrace in log' do
        expect(logger_service).to receive(:error).with(message: include("Error backtrace:\nline1\nline2\nline3"))
        subject
      end
    end
  end
end
