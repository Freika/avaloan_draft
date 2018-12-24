def loans
  loans = [
    {
      title: 'Kate',
      balance: 65_382.0,
      rate: 10,
      payment: 25_000.0
    },
    {
      title: 'Alfa',
      balance: 174_523.0,
      rate: 17,
      payment: 6_500.0
    }
  ].sort_by { |loan| loan[:title] }
end

monthly_payment = 40_000
money_left = monthly_payment

while total_debt > 0 do
  calculate_month_for(loan, money_left)
end

def calculate_month_for(loan, money_left)
  interest = calculate_interest(loan)
  new_balance

  {
    balance: new_balance,
    rate: loan[:rate],
    payment: loan[:payment],
    current_payment: current_payment,
    interest: interest,
    snowball: current_loan_extra_payment,
  }
end


def calculate_interest(loan)
  (loan[:balance] * (loan[:rate] * 0.01) / 12).round(2)
end
