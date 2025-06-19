import UIKit

class LeaseResultsViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var LeaseTermOutput: UILabel!
    @IBOutlet weak var PaymentAndInterestRateOutput: UILabel!
    @IBOutlet weak var UpfrontPaymentOutput: UILabel!
    @IBOutlet weak var TradeInAmountOutput: UILabel!
    @IBOutlet weak var LeasedAmountBeforeTaxOutput: UILabel!
    @IBOutlet weak var SalesTaxOutput: UILabel!
    @IBOutlet weak var LeasedAmountIncludingTaxOutput: UILabel!
    @IBOutlet weak var TotalAccumilatedInterestOutput: UILabel!
    @IBOutlet weak var TotalCostOutput: UILabel!
    @IBOutlet weak var ResidualValueBeforeTaxOutput: UILabel!
    @IBOutlet weak var ResidualValueAfterTaxOutput: UILabel!
    @IBOutlet weak var EndDateOutput: UILabel!

    // passed-in data
    var leaseQuote : LeaseQuote?
    var leaseResult: LeaseResult?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let q = leaseQuote, let r = leaseResult else { return }

        // 1) Term in months
        LeaseTermOutput.text = "\(q.leaseTermMonths) mo"

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

        // 5) Leased amount before tax
        LeasedAmountBeforeTaxOutput.text = String(format: "$ %.2f", r.leasedBeforeTax)

        // 6) Sales tax
        SalesTaxOutput.text = String(format: "$ %.2f", r.salesTaxAmount)

        // 7) Leased amount including tax
        LeasedAmountIncludingTaxOutput.text = String(format: "$ %.2f", r.leasedIncludingTax)

        // 8) Total interest
        TotalAccumilatedInterestOutput.text = String(format: "$ %.2f", r.totalAccumulatedInterest)

        // 9) Total lease cost
        TotalCostOutput.text = String(format: "$ %.2f", r.totalLeaseCost)

        // 10) Residual before tax
        ResidualValueBeforeTaxOutput.text = String(format: "$ %.2f", r.residualValueAmount)

        // 11) Residual including tax
        ResidualValueAfterTaxOutput.text = String(format: "$ %.2f", r.residualValueIncludingTax)

        // 12) Lease-end date
        let df = DateFormatter()
        df.dateStyle = .medium
        EndDateOutput.text = df.string(from: r.payOffDate)
    }
    @IBAction func DismissPressed(_ sender: UIButton) {
        print("💥 DismissPressed tapped")
        dismiss(animated: true)
    }
}
