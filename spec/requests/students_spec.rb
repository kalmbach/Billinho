require 'rails_helper'
require "#{Rails.root}/lib/c_p_f_helper"

RSpec.describe 'Students', type: :request do
  describe 'GET /students' do
    let!(:students) { FactoryBot.create_list(:student, 5) }

    context 'with pagination params' do
      before { get '/students?page=1&count=3' }

      it 'returns page number' do
        expect(json).to include('page' => 1)
      end

      it 'returns paginated results' do
        expect(json['items'].size).to eq(3)
      end
    end

    context 'without pagination params' do
      before { get '/students' }

      it 'returns first page number' do
        expect(json).to include('page' => 1)
      end

      it 'returns all results for first page' do
        expect(json['items'].size).to eq(5)
      end
    end

    context 'when request is valid' do
      before { get '/students?page=1&count=1' }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns students' do
        expect(json['items']).not_to be_empty
      end

      it 'returns a formatted response' do
        expect(json).to include(
          'items' =>
            a_collection_containing_exactly(
              a_hash_including(
                'id',
                'name',
                'cpf',
                'birthdate',
                'payment_method'
              )
            )
        )
      end
    end

    context 'when request has an error' do
      before do
        allow(Student).to receive(:page).and_raise('Internal Bleeding')
        get '/students'
      end

      it 'returns status code 500' do
        expect(response).to have_http_status(500)
      end

      it 'returns error message' do
        expect(json['error']).to eq('Internal Bleeding')
      end
    end
  end

  describe 'GET /students/id' do
    let!(:student) { FactoryBot.create(:student) }

    context 'when id exists' do
      before { get "/students/#{student.id}" }

      it 'returns a student' do
        expect(json).to_not be_empty
        expect(json).to include('id' => student.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a formatted response' do
        expect(json).to include(
          'id',
          'name',
          'cpf',
          'birthdate',
          'payment_method'
        )
      end
    end

    context 'when id doesnt exists' do
      before { get '/students/0' }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'POST /students' do
    let(:valid_student) do
      {
        name: 'Bruce Wayne',
        birthdate: '30/03/1939',
        payment_method: 'credit_card',
        cpf: CPFHelper.build
      }
    end

    let(:invalid_student) do
      { name: '', birthdate: nil, payment_method: 'money', cpf: '1' }
    end

    context 'when request is valid' do
      before { post '/students', params: valid_student }

      it 'creates a student' do
        expect(json).to include('id' => Student.last.id)
      end

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end
    end

    context 'when request is invalid' do
      before { post '/en/students', params: invalid_student }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(json['error']).to include('cpf is invalid')
        expect(json['error']).to include('name can\'t be blank')
        expect(json['error']).to include(
          'payment_method is not included in the list'
        )
      end
    end
  end
end
