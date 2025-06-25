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
    
    private let moneyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.groupingSeparator = ","
        f.locale = .current
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let q = leaseQuote, let r = leaseResult else { return }

        LeaseTermOutput.text = "\(q.leaseTermMonths) mo"

        let pay   = moneyFormatter.string(from: r.periodicPayment as NSNumber) ?? "–"
        let rate  = String(format: "%.2f%%", q.annualInterest)
        PaymentAndInterestRateOutput.text = "$ \(pay)   \(rate)"

        let down  = moneyFormatter.string(from: r.upfrontPayment as NSNumber) ?? "–"
        UpfrontPaymentOutput.text = "$ \(down)"

        let trade = moneyFormatter.string(from: (q.tradeInValue - q.amountOwed) as NSNumber) ?? "–"
        TradeInAmountOutput.text = "$ \(trade)"

        let before = moneyFormatter.string(from: r.leasedBeforeTax as NSNumber) ?? "–"
        LeasedAmountBeforeTaxOutput.text = "$ \(before)"

        let tax     = moneyFormatter.string(from: r.salesTaxAmount as NSNumber) ?? "–"
        SalesTaxOutput.text = "$ \(tax)"

        let incl    = moneyFormatter.string(from: r.leasedIncludingTax as NSNumber) ?? "–"
        LeasedAmountIncludingTaxOutput.text = "$ \(incl)"

        let interest = moneyFormatter.string(from: r.totalAccumulatedInterest as NSNumber) ?? "–"
        TotalAccumilatedInterestOutput.text = "$ \(interest)"

        let total   = moneyFormatter.string(from: r.totalLeaseCost as NSNumber) ?? "–"
        TotalCostOutput.text = "$ \(total)"

        let resid   = moneyFormatter.string(from: r.residualValueAmount as NSNumber) ?? "–"
        ResidualValueBeforeTaxOutput.text = "$ \(resid)"

        let residIncl = moneyFormatter.string(from: r.residualValueIncludingTax as NSNumber) ?? "–"
        ResidualValueAfterTaxOutput.text = "$ \(residIncl)"

        let df = DateFormatter()
        df.dateStyle = .medium
        EndDateOutput.text = df.string(from: r.payOffDate)
    }
    
    @IBAction func SavePressed(_ sender: UIButton) {
        guard let q = leaseQuote, let r = leaseResult else { return }

        // Build and store your SavedQuote
        let sq = SavedQuote(
          type:           .lease,
          vehiclePrice:   q.vehiclePrice,
          termMonths:     q.leaseTermMonths,
          paymentsPerYear:q.paymentsPerYear,
          payment:        r.periodicPayment,
          interestRate:   q.annualInterest,
          downPayment:    q.downPayment,
          salesTaxPercent:q.salesTaxPercent,
          totalCost:      r.totalLeaseCost
        )
        QuoteStore.shared.add(sq)

        // Quick “toast” alert
        let alert = UIAlertController(title: nil, message: "Quote Saved!", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true)
        }
    }

    @IBAction func DismissPressed(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
