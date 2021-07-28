require 'rails_helper'

RSpec.describe Enrollment, type: :model do
  it { expect(subject).to belong_to(:student) }
  it { expect(subject).to have_many(:bills) }

  it { expect(subject).to validate_presence_of(:amount) }
  it do
    expect(subject).to(
      validate_numericality_of(:amount).only_integer.is_greater_than(0)
    )
  end

  it { expect(subject).to validate_presence_of(:installments) }
  it do
    expect(subject).to(
      validate_numericality_of(:installments).only_integer.is_greater_than(1)
    )
  end

  it { expect(subject).to validate_presence_of(:due_day) }
  it do
    expect(subject).to(
      validate_numericality_of(:due_day)
        .only_integer
        .is_greater_than_or_equal_to(1)
        .is_less_than_or_equal_to(31)
    )
  end
end
