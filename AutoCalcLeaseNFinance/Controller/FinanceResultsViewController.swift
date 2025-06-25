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
    
    // a reusable formatter:
    private let moneyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.groupingSeparator = ","            // e.g. "1,234.56"
        f.locale = .current                  // uses the user’s locale
        return f
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let q = financeQuote, let r = financeResult else { return }

        // 1) Term in months
        FinanceTermOutput.text = "\(q.loanTermMonths) mo"


        // For every dollar amount, use the formatter:
        let pay     = moneyFormatter.string(from: r.periodicPayment as NSNumber) ?? "–"
        let rate    = String(format: "%.2f%%", q.annualInterest)
        PaymentAndInterestRateOutput.text = "$ \(pay)   \(rate)"

        let down    = moneyFormatter.string(from: r.upfrontPayment as NSNumber) ?? "–"
        UpfrontPaymentOutput.text = "$ \(down)"

        let tradeIn = moneyFormatter.string(from: (q.tradeInValue - q.amountOwed) as NSNumber) ?? "–"
        TradeInAmountOutput.text = "$ \(tradeIn)"

        let before  = moneyFormatter.string(from: r.financedBeforeTax as NSNumber) ?? "–"
        FinancedAmountBeforeTaxOutput.text = "$ \(before)"

        let tax     = moneyFormatter.string(from: r.salesTaxAmount as NSNumber) ?? "–"
        SalesTaxOutput.text = "$ \(tax)"

        let incl    = moneyFormatter.string(from: r.financedIncludingTax as NSNumber) ?? "–"
        FinancedAmountIncludingTaxOutput.text = "$ \(incl)"

        let interest = moneyFormatter.string(from: r.totalAccumulatedInterest as NSNumber) ?? "–"
        TotalAccumilatedInterestOutput.text = "$ \(interest)"

        let total   = moneyFormatter.string(from: r.totalCost as NSNumber) ?? "–"
        TotalCostOutput.text = "$ \(total)"

        let df = DateFormatter()
        df.dateStyle = .medium
        EndDateOutput.text = df.string(from: r.payOffDate)
    }
    
    @IBAction func SavePressed(_ sender: UIButton) {
        guard let q = financeQuote, let r = financeResult else { return }

         // Build and store your SavedQuote as before
         let sq = SavedQuote(
           type:           .finance,
           vehiclePrice:   q.vehiclePrice,
           termMonths:     q.loanTermMonths,
           paymentsPerYear:q.paymentsPerYear,
           payment:        r.periodicPayment,
           interestRate:   q.annualInterest,
           downPayment:    q.downPayment,
           salesTaxPercent:q.salesTaxPercent,
           totalCost:      r.totalCost
         )
         QuoteStore.shared.add(sq)

         // Present a quick 1.5s “toast”
         let alert = UIAlertController(title: nil, message: "Quote Saved!", preferredStyle: .alert)
         present(alert, animated: true)
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
             alert.dismiss(animated: true)
         }
    }

    @IBAction func DismissPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
