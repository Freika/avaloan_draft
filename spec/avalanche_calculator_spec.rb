require './avalanche_calculator'
RSpec.describe AvalancheCalculator do
  describe "#call" do
    let(:sum) { 15_000 }
    let(:kate_loan) do
      {
        title: 'Kate',
        payment: 3_800,
        percent: 10,
        amount: 23_000
      }
    end
    let(:alfa_loan) do
      {
        title: 'Alfa',
        payment: 2_500,
        percent: 16,
        amount: 36_000
      }
    end
    let(:halva_loan) do
      {
        title: 'Halva',
        payment: 7_200,
        percent: 19,
        amount: 122_200
      }
    end

    it "calculates all payments" do
      loans = [kate_loan, alfa_loan, halva_loan]
      total_debt = AvalancheCalculator.new(loans, sum).call


      expect(total_debt).to eq(0)
    end
  end
end
