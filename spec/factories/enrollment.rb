FactoryBot.define do
  factory :enrollment do
    amount { SecureRandom.rand(1_000_000..2_000_000).to_i }
    installments { SecureRandom.rand(2..12).to_i }
    due_day { SecureRandom.rand(1..31).to_i }

    student { association :student }
  end
end
