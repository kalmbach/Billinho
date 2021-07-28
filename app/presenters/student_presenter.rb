class StudentPresenter
  attr_reader :student

  def initialize(student)
    @student = student
  end

  def as_json
    {
      id: student.id,
      name: student.name,
      cpf: student.cpf,
      birthdate: student.birthdate&.strftime('%d/%m/%Y'),
      payment_method:
        I18n.t(
          "activerecord.models.student.payment_method.#{student.payment_method}"
        )
    }
  end
end
