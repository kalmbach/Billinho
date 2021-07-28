class EnrollmentsController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods

  # TODO: is a bad practice to store secrets in code
  # This is only an excercise.
  #
  # TODO: é uma má prática armazenar segredos no código
  # Este é apenas um exercício.
  http_basic_authenticate_with name: 'admin_ops',
                               password: 'billing',
                               except: %i[index show]

  def index
    page = index_params[:page] || 1
    count = index_params[:count]

    enrollments = Enrollment
    enrollments = enrollments.page(page)
    enrollments = enrollments.per(count) if count.present?

    render json: EnrollmentsPresenter.new(enrollments.all, page).as_json
  end

  def show
    enrollment = Enrollment.find(params[:id])
    render json: EnrollmentPresenter.new(enrollment).as_json
  end

  def create
    enrollment = Enrollment.new(enrollment_params)

    if enrollment.save
      BillingService.new(enrollment).create_installments!
      render json: EnrollmentPresenter.new(enrollment).as_json, status: :created
    else
      render json: {
               error:
                 enrollment
                   .errors
                   .map do |e|
                     "#{e.attribute} #{I18n.t("errors.messages.#{e.type}", e.options)}"
                   end
                   .join('. ')
             },
             status: :unprocessable_entity
    end
  end

  def index_params
    params.permit(:page, :count)
  end

  def enrollment_params
    params.permit(:student_id, :amount, :installments, :due_day)
  end
end
