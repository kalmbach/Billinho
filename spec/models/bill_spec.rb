require 'rails_helper'

RSpec.describe Bill, type: :model do
  it { expect(subject).to belong_to(:enrollment) }

  it { expect(subject).to validate_presence_of(:amount) }
  it do
    expect(subject).to(
      validate_numericality_of(:amount).only_integer.is_greater_than(0)
    )
  end

  it { expect(subject).to validate_presence_of(:status) }
  it do
    expect(subject).to(
      validate_inclusion_of(:status).in_array(%w[open pending paid])
    )
  end

  it { expect(subject).to validate_presence_of(:due_date) }
  it { expect(subject).to allow_values('28/02/2021').for(:due_date) }
  it { expect(subject).to_not allow_values('31/02/2021').for(:due_date) }
end
