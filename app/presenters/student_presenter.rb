class StudentPresenter
  attr_reader :student

  def initialize(student)
    @student = student
  end

  def as_json
    {
      id: student.id,
      name: student.name,
      cpf: formatted_cpf(student.cpf),
      birthdate: student.birthdate&.strftime('%d/%m/%Y'),
      payment_method:
        I18n.t(
          "activerecord.models.student.payment_method.#{student.payment_method}"
        )
    }
  end

  def formatted_cpf(cpf)
    # 502.757.480-06
    [[cpf[0..2], cpf[3..5], cpf[6..8]].join('.'), cpf[9..11]].join('-')
  end

  private :formatted_cpf
end
