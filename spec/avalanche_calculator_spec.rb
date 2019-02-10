require './avalanche_calculator'
RSpec.describe AvalancheCalculator do
  describe "#call" do
    let(:sum) { 15_000 }
    let(:first_loan) do
      {
        title: 'Loan #1',
        payment: 3_800,
        percent: 10,
        amount: 23_000
      }
    end
    let(:second_loan) do
      {
        title: 'Loan #2',
        payment: 2_500,
        percent: 16,
        amount: 36_000
      }
    end
    let(:third_loan) do
      {
        title: 'Loan #3',
        payment: 7_200,
        percent: 19,
        amount: 122_200
      }
    end

    it "calculates all payments" do
      loans = [first_loan, second_loan, third_loan]
      calculated_loans = AvalancheCalculator.new(loans, sum).call

      p calculated_loans

      # expect(total_Loan).to eq(0)
    end
  end
end
