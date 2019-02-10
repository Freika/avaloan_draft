require './month_calculator'
RSpec.describe MonthCalculator do
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

    describe 'Reducing loans by payment size' do
      it "for kate" do
        loans = [kate_loan, alfa_loan, halva_loan]
        calculator = MonthCalculator.new(loans, sum).call

        expect(kate_loan[:amount]).to eq(19_200)
      end

      it "for alfa" do
        loans = [kate_loan, alfa_loan, halva_loan]
        calculator = MonthCalculator.new(loans, sum).call

        expect(alfa_loan[:amount]).to eq(33_500)
      end

      it "for halva" do
        loans = [kate_loan, alfa_loan, halva_loan]
        calculator = MonthCalculator.new(loans, sum).call

        expect(halva_loan[:amount]).to eq(113_500)
      end
    end
  end
end
