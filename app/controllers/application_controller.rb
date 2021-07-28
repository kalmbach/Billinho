class ApplicationController < ActionController::API
  include ExceptionHandler

  around_action :switch_locale

  def routing_error
    render json: { error: 'not_found' }, status: :not_found
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def switch_locale(&action)
    I18n.with_locale(params[:locale], &action)
  end
end
