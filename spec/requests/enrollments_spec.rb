require 'rails_helper'

RSpec.describe 'Enrollments', type: :request do
  describe 'GET /enrollments' do
    let!(:enrollments) { FactoryBot.create_list(:enrollment, 5) }

    context 'whit pagination params' do
      before { get '/enrollments?page=1&count=3' }

      it 'returns page number' do
        expect(json).to include('page' => 1)
      end

      it 'returns paginated results' do
        expect(json['items'].size).to eq(3)
      end
    end

    context 'without pagination params' do
      before { get '/enrollments' }

      it 'returns first uage number' do
        expect(json).to include('page' => 1)
      end

      it 'returns all results for first page' do
        expect(json['items'].size).to eq(5)
      end
    end

    context 'when request is valid' do
      before { get '/enrollments?page=1&count=1' }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns enrollments' do
        expect(json['items']).not_to be_empty
      end

      it 'returns formatted response' do
        expect(json).to include(
          'items' =>
            a_collection_containing_exactly(
              a_hash_including(
                'id',
                'student_id',
                'amount',
                'installments',
                'due_day',
                'bills'
              )
            )
        )
      end
    end

    context 'when request has an error' do
      before do
        allow(Enrollment).to receive(:page).and_raise('Internal Bleeding')
        get '/enrollments'
      end

      it 'returns status code 500' do
        expect(response).to have_http_status(500)
      end

      it 'returns error message' do
        expect(json['error']).to eq('Internal Bleeding')
      end
    end
  end

  describe 'GET /enrollments/id' do
    let!(:enrollment) { FactoryBot.create(:enrollment, installments: 2) }

    context 'when id exists' do
      before do
        BillingService.new(enrollment).create_installments!
        get "/enrollments/#{enrollment.id}"
      end

      it 'returns a enrollment' do
        expect(json).to_not be_empty
        expect(json).to include('id' => enrollment.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a formatted response' do
        expect(json).to include(
          'id',
          'student_id',
          'amount',
          'installments',
          'due_day',
          'bills' =>
            a_collection_containing_exactly(
              a_hash_including('id', 'due_date', 'status', 'amount'),
              a_hash_including('id', 'due_date', 'status', 'amount')
            )
        )
      end
    end

    context 'when id doesnt exists' do
      before { get '/enrollments/0' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /enrollments' do
    let(:student) { FactoryBot.create(:student) }

    let(:valid_enrollment) do
      { amount: 1_200_000, installments: 3, due_day: 5, student_id: student.id }
    end

    let(:invalid_enrollment) do
      { amount: 0, installments: 0, due_day: 0, student_id: 0 }
    end

    let(:authorization) do
      ActionController::HttpAuthentication::Basic.encode_credentials(
        'admin_ops',
        'billing'
      )
    end

    context 'when request is not authorized' do
      before { post '/enrollments', params: valid_enrollment }

      it 'returns unauthorized response' do
        expect(response).to have_http_status(401)
      end
    end

    context 'when request is valid' do
      before do
        post '/enrollments',
             params: valid_enrollment,
             headers: {
               'HTTP_AUTHORIZATION' => authorization
             }
      end

      it 'creates an enrollment' do
        expect(json).to include('id' => Enrollment.last.id)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when request is invalid' do
      before do
        post '/en/enrollments',
             params: invalid_enrollment,
             headers: {
               'HTTP_AUTHORIZATION' => authorization
             }
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(json['error']).to include('student can\'t be blank')
        expect(json['error']).to include('amount must be greater than 0')
        expect(json['error']).to include('installments must be greater than 1')
        expect(json['error']).to include(
          'due_day must be greater than or equal to 1'
        )
      end
    end
  end
end
