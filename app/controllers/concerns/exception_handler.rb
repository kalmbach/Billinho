module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |e|
      render json: { error: e.message }, status: :not_found
    end

    rescue_from ActiveRecord::RecordInvalid do |e|
      render json: { error: e.message }, status: :unprocessable_entity
    end

    rescue_from RuntimeError do |e|
      render json: { error: e.message }, status: :internal_server_error
    end

    rescue_from ActionController::RoutingError do
      render json: { error: 'not_found' }, status: :not_found
    end
  end
end
