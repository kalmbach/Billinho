class StudentsController < ApplicationController
  def index
    page = index_params[:page] || 1
    count = index_params[:count]

    students = Student
    students = students.page(page)
    students = students.per(count) if count.present?

    render json: StudentsPresenter.new(students.all, page).as_json
  end

  def show
    student = Student.find(params[:id])
    render json: StudentPresenter.new(student).as_json
  end

  def create
    student = Student.new(student_params)

    if student.save
      render json: { id: student.id }, status: :created
    else
      render json: {
               error:
                 student
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

  def student_params
    params.permit(:name, :cpf, :birthdate, :payment_method)
  end
end
