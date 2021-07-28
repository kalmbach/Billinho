require 'rails_helper'

RSpec.describe Student, type: :model do
  # A valid subject is required for the
  # uniqueness validator test
  subject do
    Student.new(name: 'Pepe', cpf: '85266161884', payment_method: 'boleto')
  end

  it { expect(subject).to have_many(:enrollments) }

  it { expect(subject).to validate_presence_of(:name) }
  it { expect(subject).to validate_presence_of(:cpf) }
  it { expect(subject).to validate_uniqueness_of(:cpf).case_insensitive }

  it do
    expect(subject).to(
      validate_inclusion_of(:payment_method).in_array(%w[credit_card boleto])
    )
  end

  it { expect(subject).to allow_values('28/02/2021').for(:birthdate) }
  it { expect(subject).to_not allow_values('31/02/2021').for(:birthdate) }

  it { expect(subject).to allow_values('85266161884').for(:cpf) }
  it { expect(subject).to_not allow_values('85266161883').for(:cpf) }

  it { expect(subject).to allow_values('54834607151').for(:cpf) }
  it { expect(subject).to_not allow_values('54834607152').for(:cpf) }
end
