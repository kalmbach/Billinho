class Student < ApplicationRecord
  has_many :enrollments

  validates :name, presence: true
  validates :cpf,
            cpf: true,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }

  validates :payment_method,
            presence: true,
            inclusion: {
              in: %w[credit_card boleto]
            }

  validates :birthdate, date: true
end
