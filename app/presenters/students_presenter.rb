class StudentsPresenter
  attr_reader :students, :page

  def initialize(students, page)
    @students = students
    @page = page
  end

  def as_json
    {
      page: page.to_i,
      items: students.map { |student| StudentPresenter.new(student).as_json }
    }
  end
end
