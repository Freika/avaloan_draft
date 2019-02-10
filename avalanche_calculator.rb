require './month_calculator'
require 'byebug'

class AvalancheCalculator
  def initialize(loans, sum)
    @loans = loans.sort_by { |loan| loan[:percent] } # cheaper is earlier
    @sum = sum
  end

  def call
    calculate_payments(@loans, @sum)
  end

  private

  def calculate_payments(loans, sum)
    total_debt = loans.map { |loan| loan[:amount] }.sum
    month_number = 0
    result = []

    while total_debt > 0
      calculated_month = MonthCalculator.new(loans, sum).call

      total_debt = calculated_month[:sum]
      month_loans = calculated_month[:loans]
      month_number += 1

      month = { month_number: month_number, loans: month_loans }

      result << month
    end

    result
  end
end
