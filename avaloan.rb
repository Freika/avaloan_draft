require 'date'
require 'sinatra'
require 'chronic'
require 'slim'
require 'byebug'

get '/' do
  slim :index, locals: { loans: loans, payments: calculate }
end


def loans
  loans = [
    # {
    #   title: 'Tinkoff',
    #   balance: 98_139,
    #   rate: 40,
    #   payment: 7_000
    # },
    # {
    #   title: 'Alfa',
    #   balance: 59_703,
    #   rate: 30,
    #   payment: 3_200
    # },
    # {
    #   title: 'MacBook',
    #   balance: 31_590,
    #   rate: 20,
    #   payment: 6_318
    # },
    # {
    #   title: 'iPhone',
    #   balance: 56_214,
    #   rate: 20,
    #   payment: 2_750
    # }
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

def calculate
  balance_date = Date.today # Дата, на которую указан баланс долгов
  monthly_payment = 40_000.0 # Ежемесячный платеж на все долги
  total_debt = loans.map { |d| d[:balance] }.sum # Общая сумма всех долгов
  total_monthly_payment = loans.map { |d| d[:payment] }.sum # Общая сумма всех минимальных платежей
  extra_payment = monthly_payment - total_monthly_payment # Initial snowball, оставшееся после минимальных платежей
  avaloans = loans.sort_by { |d| d[:rate] }.reverse # Долги, отсортированные по дороговизне, от дорогого в дешевому
  payments = [] # Массив с платежами

  # 360 months of calculations
  (1..360).to_a.each do |n|
    # Если initial snowball не равен сумме платежа - сумма минимальных платежей,
    # то устанавливаем его равным месячному платежу - сумма всех
    # if extra_payment != monthly_payment - total_monthly_payment
    #   extra_payment = monthly_payment - avaloans.map { |d| d[:payment] }.sum
    # end

    # Для каждого отсортированного долга запускаем цикл
    avaloans.map! do |loan|
      # Комиссия по платежу = баланс * проценты / 12 месяцев
      interest = calculate_interest(loan)

      # Если этот долг первый в списке, то сноуболл этого цикла равен сноуболлу
      current_loan_extra_payment = avaloans[0] == loan ? extra_payment : 0

      # Считаем детали платежа
      payment_details = calculate_payment_details(loan, avaloans, extra_payment)

      # номер месяца устанавливаем равным номеру цикла или 0, если почему-то номера цикла нет
      loan[:month_number] = n || 0

      # В список платежей помещаем обновленное тело долга
      payments << loan

      current_payment = loan[:balance] - payment_details[:new_balance]

      # Возвращаем результат вычисления для текущего долга.
      {
        title: loan[:title],
        balance: payment_details[:new_balance],
        rate: loan[:rate],
        payment: loan[:payment],
        current_payment: current_payment,
        interest: interest,
        extra_payment: current_loan_extra_payment,
        month_number: n
      }
    end

    # если сумма всех задолженностей <= нулю, прерываем ежемесячный расчет
    break if avaloans.map { |s| s[:balance] }.sum <= 0
  end

  # Сортируем платежи по месяцам
  payments.sort_by! { |p| p[:month_number] }

  # Забираем массив месяцев
  months = payments.map { |payment| payment[:month_number] }.uniq


  calculations_result = {
    payments: payments,
    months_number: payments.first[:month_number],
    # sorted_payments: sorted_payments
  }

  sorted_payments = []

  # для каждого месяца
  months.each do |month|
    # собираем его платежи и сортируем по дороговизне
    ps = payments.select { |payment| payment[:month_number] == month }.sort_by { |d| d[:rate] }.reverse

    sorted_payments << { month => ps }
  end

  # Возвращаем список месяцев, внутри которого содержатся принадлежащие им платежи
  sorted_payments

  # calculations_result
end

def avalanchable?(loans, current_loan)
  # Текущий долг — самый дорогой?
  loans.sort_by { |l| [l[:rate], l[:balance]] }.last == current_loan
end

def calculate_interest(loan)
  (loan[:balance] * (loan[:rate] * 0.01) / 12).round(2)
end

def calculate_payment_details(loan, avaloans, extra_payment)
  # Если платеж больше баланса
  if loan[:payment] > loan[:balance]
    # То полностью выплачиваем долг
    new_balance = 0
    # И добавляем к сноуболлу разницу платежа и баланса
    extra_payment += loan[:payment] - loan[:balance]

    ###
    ### Находим следующий по дороговизне долг
    next_loan = (avaloans - [loan]).last
    calculate_payment_details(next_loan, avaloans, extra_payment)
    ### и запускаем этот же метод для него
    ###

  # Если платёж + сноуболл больше, чем баланс
  elsif loan[:payment] + extra_payment > loan[:balance]
    # То полностью выплачиваем долг
    new_balance = 0
    # и из суммы платежа и сноуболла вычитаем баланс
    extra_payment = loan[:payment] + extra_payment - loan[:balance]

    ###
    next_loan = (avaloans - [loan]).last
    calculate_payment_details(next_loan, avaloans, extra_payment)
    ### Находим следующий по дороговизне долг
    ### и запускаем этот же метод для него
    ###

  # если текущий долг — самый дорогой?
  elsif avalanchable?(avaloans, loan)
    # То вычитаем из баланса сумму платежа и сноуболла
    new_balance = loan[:balance] - (loan[:payment] + extra_payment)
  else
    # вычитаем из баланса платеж
    new_balance = loan[:balance] - loan[:payment]
  end

  {
    new_balance: new_balance,
    extra_payment: extra_payment || 0
  }
end

calculate.each { |c| p c; p '' }
