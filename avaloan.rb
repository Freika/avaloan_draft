require 'date'
require 'sinatra'
require 'chronic'

get '/' do
  erb :index, locals: { loans: loans, payments: calculate }
end

def loans
  loans = [
    {
      title: 'Tinkoff',
      balance: 98_139,
      rate: 40,
      payment: 7_000
    },
    {
      title: 'Alfa',
      balance: 59_703,
      rate: 30,
      payment: 3_200
    },
    {
      title: 'MacBook',
      balance: 31_590,
      rate: 20,
      payment: 6_318
    },
    {
      title: 'iPhone',
      balance: 56_214,
      rate: 20,
      payment: 2_750
    }
  ]
end

def calculate
  balance_date = Date.today
  monthly_payment = 40_000
  total_debt = loans.map { |d| d[:balance] }.sum
  total_monthly_payment = loans.map { |d| d[:payment] }.sum
  extra_payment = monthly_payment - total_monthly_payment
  avaloans = loans.sort_by { |d| d[:rate] }.reverse
  payments = []

  # 360 months of calculations
  (1..360).to_a.each do |n|
    if extra_payment != monthly_payment - total_monthly_payment
      extra_payment = monthly_payment - avaloans.map { |d| d[:payment] }.sum
    end

    avaloans.map! do |loan|
      interest = (loan[:balance] * (loan[:rate] * 0.01) / 12).round(2)
      current_loan_extra_payment = extra_payment if avaloans[0] == loan

      if loan[:balance] < loan[:payment]
        new_balance = 0
        extra_payment += loan[:payment] - loan[:balance]
        p "FIRST condition worked on #{loan[:title]}, MONTH #{n}"
      elsif loan[:balance] < loan[:payment] + extra_payment
        new_balance = 0
        current_loan_extra_payment = extra_payment
        extra_payment = current_loan_extra_payment - loan[:balance]
        p "SECOND condition worked on #{loan[:title]}, MONTH #{n}"
      elsif avalanchable?(avaloans, loan)
        new_balance = loan[:balance] - (loan[:payment] + extra_payment)
        current_loan_extra_payment = extra_payment
        p "THIRD condition worked on #{loan[:title]}, MONTH #{n}"
      else
        new_balance = loan[:balance] - loan[:payment]
        p "FOURTH condition worked on #{loan[:title]}, MONTH #{n}"
      end

      loan[:month_number] = n || 0

      payments << loan

      {
        title: loan[:title],
        balance: new_balance,
        rate: loan[:rate],
        payment: loan[:payment],
        interest: interest,
        extra_payment: current_loan_extra_payment || 0,
        month_number: n
      }
    end

    # break if avaloans.empty?
    break if avaloans.map { |s| s[:balance] }.sum <= 0
  end

  # p payments

  payments.sort_by! { |p| p[:month_number] }

  months = payments.map { |payment| payment[:month_number] }.uniq

  monthly_sorted_payments = []

  months.each do |month|
    month_payments = payments.select { |p| p[:month_number] == month }.sort_by { |d| d[:rate] }.reverse

    monthly_sorted_payments << { month => month_payments }
  end

  # p monthly_sorted_payments

  {
    payments: payments,
    months_number: payments.first[:month_number],
    monthly_sorted_payments: monthly_sorted_payments
  }
end

def avalanchable?(loans, current_loan)
  loans.sort_by { |d| [d[:rate], d[:balance]] }.last == current_loan
end

# Todo:
# 1. Correctly assign extra payment to most expensive loan
# 2. Don't mix payments
# 3. Don't subtract extra payment from non-assigned loans
