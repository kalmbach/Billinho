class Bill < ApplicationRecord
  belongs_to :enrollment

  validates :amount,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :status, presence: true, inclusion: { in: %w[open pending paid] }

  validates :due_date, date: true, presence: true

  default_scope { order('due_date ASC') }
end
