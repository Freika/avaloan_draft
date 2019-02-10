# Splits available sum between all loans, starting from cheapest
# to most expensive, which gets full snowball
class MonthCalculator
  def initialize(loans, sum)
    @loans = loans.sort_by { |loan| loan[:percent] } # cheaper is earlier
    @sum = sum
  end

  def call
    run_cycle(@loans, @sum)
  end

  private

  def run_cycle(loans, sum)
    while sum > 0 do
      sum = split_sum(loans, sum)
    end

    loans.inject(0) { |memo, loan| memo + loan[:amount] }
  end

  def split_sum(loans, sum)
    if sum > 0
      loans.each do |loan|
        if sum > loan[:payment]
          loan[:amount] -= loan[:payment]
          sum -= loan[:payment]
        else
          loan[:amount] -= sum
          sum = 0
        end

        if loan == loans.last
          loan[:amount] -= sum
          sum = 0
        end
      end
    end

    sum
  end
end
