class EnrollmentPresenter
  attr_reader :enrollment

  def initialize(enrollment)
    @enrollment = enrollment
  end

  def as_json
    {
      id: enrollment.id,
      student_id: enrollment.student_id,
      amount: enrollment.amount,
      installments: enrollment.installments,
      due_day: enrollment.due_day,
      bills: enrollment.bills.map { |bill| BillPresenter.new(bill).as_json }
    }
  end
end
