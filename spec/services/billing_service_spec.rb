describe BillingService do
  let!(:enrollment) do
    FactoryBot.create(
      :enrollment,
      amount: 1_300_000,
      installments: 3,
      due_day: 10
    )
  end

  let(:first_bill) { 433_333 } # enrollment.amount / 3
  let(:last_bill) { 433_334 } # compensated bill

  context '#create_installments!' do
    before { BillingService.new(enrollment).create_installments! }

    it 'creates bills successfully' do
      expect(enrollment.bills).not_to be_empty
    end

    it 'creates the right amount of bills' do
      expect(enrollment.bills.size).to eq(enrollment.installments)
    end

    it 'creates bills for the total amount' do
      expect(enrollment.bills.sum('amount')).to eq(enrollment.amount)
    end

    it 'divides the amount in installments' do
      expect(enrollment.bills.first.amount).to eq(first_bill)
    end

    it 'compensates the last bill to the total amount' do
      expect(enrollment.bills.last.amount).to eq(last_bill)
    end

    it 'creates bills that due on the requested day' do
      expect(enrollment.bills.first.due_date.day).to eq(enrollment.due_day)
    end
  end

  context 'when due_day > today' do
    before do
      Timecop.travel(Time.local(2021, 7, 1, 12, 0, 0))
      BillingService.new(enrollment).create_installments!
    end

    after { Timecop.return }

    it 'creates bills that are due from current month' do
      expect(enrollment.bills.first.due_date.month).to eq(Date.today.month)
    end

    it 'creates monthly bills' do
      expect(enrollment.bills.last.due_date.month).to eq(
        Date.today.advance(months: enrollment.installments - 1).month
      )
    end
  end

  context 'when due_day < today' do
    before do
      Timecop.travel(Time.local(2021, 7, 31, 12, 0, 0))
      BillingService.new(enrollment).create_installments!
    end

    after { Timecop.return }

    it 'creates bills that are due from next month' do
      expect(enrollment.bills.first.due_date.month).to eq(
        Date.today.next_month.month
      )
    end

    it 'creates monthly bills' do
      expect(enrollment.bills.last.due_date.month).to eq(
        Date.today.advance(months: enrollment.installments).month
      )
    end
  end

  context 'when due_day == 31 and today is 31' do
    let!(:enrollment) do
      FactoryBot.create(
        :enrollment,
        amount: 1_300_000,
        installments: 3,
        due_day: 31
      )
    end

    before do
      Timecop.travel(Time.local(2021, 1, 31, 12, 0, 0))
      BillingService.new(enrollment).create_installments!
    end

    after { Timecop.return }

    it 'creates bills that are due from next month' do
      expect(enrollment.bills.first.due_date.month).to eq(
        Date.today.next_month.month
      )
    end

    it 'creates monthly bills' do
      expect(enrollment.bills.last.due_date.month).to eq(
        Date.today.advance(months: enrollment.installments).month
      )
    end
  end

  context 'when due_day == 31 and today is April 30' do
    let!(:enrollment) do
      FactoryBot.create(
        :enrollment,
        amount: 1_300_000,
        installments: 3,
        due_day: 31
      )
    end

    before do
      Timecop.travel(Time.local(2021, 4, 30, 12, 0, 0))
      BillingService.new(enrollment).create_installments!
    end

    after { Timecop.return }

    it 'creates bills that are due from next month' do
      expect(enrollment.bills.first.due_date.month).to eq(
        Date.today.next_month.month
      )
    end

    it 'creates monthly bills' do
      expect(enrollment.bills.last.due_date.month).to eq(
        Date.today.advance(months: enrollment.installments).month
      )
    end
  end

  context 'creates bills that go from current year to next year ' do
    let!(:enrollment) do
      FactoryBot.create(
        :enrollment,
        amount: 1_300_000,
        installments: 3,
        due_day: 31
      )
    end

    before do
      Timecop.travel(Time.local(2021, 12, 1, 12, 0, 0))
      BillingService.new(enrollment).create_installments!
    end

    after { Timecop.return }

    it 'first bill is december this year' do
      expect(enrollment.bills.first.due_date.month).to eq(12)
    end

    it 'last bill is february next year' do
      expect(enrollment.bills.last.due_date.month).to eq(2)
      expect(enrollment.bills.last.due_date.year).to eq(2022)
    end
  end
end
