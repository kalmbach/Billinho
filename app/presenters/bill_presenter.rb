class BillPresenter
  attr_reader :bill

  def initialize(bill)
    @bill = bill
  end

  def as_json
    {
      id: bill.id,
      due_date: bill.due_date,
      amount: bill.amount,
      status: I18n.t("activerecord.models.bill.status.#{bill.status}")
    }
  end
end
