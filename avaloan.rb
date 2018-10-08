require 'date'
require 'sinatra'

get '/' do
  erb :index, locals: { loans: loans, avaloans: calculate }
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

  p avaloans
  results = []

  p "First extra payment is #{extra_payment}"

  # 360 months of calculations
  (1..360).to_a.each do |n|
    min_payment = avaloans.map { |d| d[:payment] }.sum
    p "total minimum payment is #{min_payment}"

    if extra_payment != monthly_payment - total_monthly_payment
      extra_payment = monthly_payment - avaloans.map { |d| d[:payment] }.sum
    end

    p "Current extra payment is #{extra_payment}"

    avaloans.map! do |loan|
      interest = (loan[:balance] * (loan[:rate] * 0.01) / 12).round(2)
      current_loan_extra_payment = extra_payment if avaloans[0] == loan
      {
        title: loan[:title],
        balance: loan[:balance] -= loan[:payment],
        rate: loan[:rate],
        payment: loan[:payment],
        interest: interest,
        extra_payment: current_loan_extra_payment
      }
    end

    avaloans.each do |loan|
      results << loan
      # Если платеж по долгу меньше суммы платежа + экстра пеймента
      if avaloans[0] == loan && loan[:balance] < loan[:payment] + extra_payment
        # То вычитаем из этой суммы платеж и возвращаем остаток
        # Остаток делаем экстра пейментом
        extra_payment = loan[:payment] + extra_payment - loan[:balance]
        # Удаляем долг из массива
        p "loan #{loan[:title]} is repaid in #{n} month"
        avaloans.delete(loan)
      elsif loan[:balance] < loan[:payment]
        extra_payment = loan[:payment] - loan[:balance]
        p "loan #{loan[:title]} is repaid in #{n} month"
        avaloans.delete(loan)
      end
    end

    break if avaloans.empty?
    # Экстра пеймент вычитаем из следующего первого долга
    avaloans[0][:balance] -= extra_payment

    p avaloans
  end

  results
end