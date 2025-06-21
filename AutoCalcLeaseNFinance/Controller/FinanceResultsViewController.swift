import UIKit

class FinanceResultsViewController: UIViewController {


    // MARK: - IBOutlets
    @IBOutlet weak var FinanceTermOutput: UILabel!
    @IBOutlet weak var PaymentAndInterestRateOutput: UILabel!
    @IBOutlet weak var UpfrontPaymentOutput: UILabel!
    @IBOutlet weak var TradeInAmountOutput: UILabel!
    @IBOutlet weak var FinancedAmountBeforeTaxOutput: UILabel!
    @IBOutlet weak var SalesTaxOutput: UILabel!
    @IBOutlet weak var FinancedAmountIncludingTaxOutput: UILabel!
    @IBOutlet weak var TotalAccumilatedInterestOutput: UILabel!
    @IBOutlet weak var TotalCostOutput: UILabel!
    @IBOutlet weak var EndDateOutput: UILabel!

    // passed-in data
    var financeQuote:  FinanceQuote?
    var financeResult: FinanceResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let q = financeQuote, let r = financeResult else { return }

        // 1) Term in months
        FinanceTermOutput.text = "\(q.loanTermMonths) mo"

        // 2) Payment & interest rate
        PaymentAndInterestRateOutput.text = String(
            format: "$ %.2f   %.2f%%",
            r.periodicPayment,
            q.annualInterest
        )

        // 3) Down payment
        UpfrontPaymentOutput.text = String(format: "$ %.2f", r.upfrontPayment)

        // 4) Net trade-in
        TradeInAmountOutput.text = String(format: "$ %.2f", q.tradeInValue - q.amountOwed)

        // 5) Financed before tax
        FinancedAmountBeforeTaxOutput.text = String(format: "$ %.2f", r.financedBeforeTax)

        // 6) Sales tax
        SalesTaxOutput.text = String(format: "$ %.2f", r.salesTaxAmount)

        // 7) Financed including tax
        FinancedAmountIncludingTaxOutput.text = String(format: "$ %.2f", r.financedIncludingTax)

        // 8) Total interest
        TotalAccumilatedInterestOutput.text = String(format: "$ %.2f", r.totalAccumulatedInterest)

        // 9) Total cost
        TotalCostOutput.text = String(format: "$ %.2f", r.totalCost)

        // 10) Pay-off date
        let df = DateFormatter()
        df.dateStyle = .medium
        EndDateOutput.text = df.string(from: r.payOffDate)
    }


    @IBAction func DismissPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
