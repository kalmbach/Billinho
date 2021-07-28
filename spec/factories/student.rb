require "#{Rails.root}/lib/c_p_f_helper"

FactoryBot.define do
  sequence(:payment_method) { |_| %w[credit_card boleto][rand(2)] }

  factory :student do
    name { Faker::Name.name }
    cpf { CPFHelper.build }
    birthdate { Faker::Date.in_date_period(year: 2000) }
    payment_method { generate(:payment_method) }
  end
end
