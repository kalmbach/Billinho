class Enrollment < ApplicationRecord
  belongs_to :student
  has_many :bills

  validates :amount,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :installments,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 1
            }

  validates :due_day,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              less_than_or_equal_to: 31
            }
end
