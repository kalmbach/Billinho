class BillingService
  attr_reader :enrollment

  def initialize(enrollment)
    @enrollment = enrollment
  end

  def create_installments!
    return if enrollment.bills.exists?

    fee = enrollment.amount / enrollment.installments

    # If you divide an amount that is not a multiple of the installments,
    # the sum of the bills will not be equal to the total since the decimals
    # are truncated. Compensate the last bill to retrieve these lost decimals.
    #
    # Se você dividir um valor que não seja um múltiplo das parcelas,
    # a soma das contas não será igual ao total, pois os decimais estão truncados.
    # Compense a última conta para recuperar esses decimais perdidos.
    compensated_fee = enrollment.amount - (fee * (enrollment.installments - 1))

    Bill.transaction do
      enrollment.installments.times do |n|
        is_last_bill = n + 1 == enrollment.installments

        Bill.create!(
          enrollment: enrollment,
          due_date: due_date(n),
          amount: is_last_bill ? compensated_fee : fee
        )
      end
    end

    raise 'No bills were created' unless enrollment.bills.exists?
  end

  def due_date(n)
    # Start this month or next one?
    # If today < due_day start this month
    # If today >= due_day start next month
    # If due_day is 31 but this month have only 30 days, jump to next month
    #
    # Começar este mês ou no próximo?
    # Se hoje < due_day começar este mês
    # Se hoje > = due_day começa no próximo mês
    # Se due_day for 31, mas este mês tiver apenas 30 dias, pule para o próximo mês
    date =
      if Date.today.end_of_month.day < enrollment.due_day
        Date.today.next_month
      else
        Date.today.day < enrollment.due_day ? Date.today : Date.today.next_month
      end

    # Advance to month of current bill
    #
    # Avançar para o mês da fatura atual
    date = date.advance(months: n)

    # Not all months have 31 or 30 days...
    # I'm looking at you February.
    # If that's the case, set the date to the end of the month
    #
    # Nem todos os meses têm 31 ou 30 dias ...
    # Estou olhando para você fevereiro.
    # Se for esse o caso, defina a data para o final do mês
    date =
      if date.end_of_month.day >= enrollment.due_day
        date.change(day: enrollment.due_day)
      else
        date.change(day: date.end_of_month.day)
      end
  end

  private :due_date
end
