require './month_calculator'

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

    while total_debt > 0
      total_debt = MonthCalculator.new(loans, sum).call
    end
  end
end
