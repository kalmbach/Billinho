class EnrollmentsPresenter
  attr_reader :enrollments, :page

  def initialize(enrollments, page)
    @enrollments = enrollments
    @page = page
  end

  def as_json
    {
      page: page.to_i,
      items:
        enrollments.map do |enrollment|
          EnrollmentPresenter.new(enrollment).as_json
        end
    }
  end
end
