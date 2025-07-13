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
    
    @IBAction func GeneratePDFPressed(_ sender: UIButton) {
      guard let q = financeQuote, let r = financeResult else { return }
      let pdfData = makeFinancePDF(quote: q, result: r)
      let vc = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
      present(vc, animated: true)
    }
    
    private func makeFinancePDF(quote q: FinanceQuote, result r: FinanceResult) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let inset: CGFloat = 40
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { ctx in
            ctx.beginPage()

            // 1) faded background
            if let bg = UIImage(named: "AutoCalc-Launch-Screen") {
                bg.draw(in: pageRect, blendMode: .normal, alpha: 0.1)
            }

            // 2) title centered at top
            let vp      = Int(round(q.vehiclePrice))
            let tp      = q.loanTermMonths
            let title   = "$\(vp) – \(tp) Month Financing Quote"
            let titleAttrs: [NSAttributedString.Key:Any] = [
                .font: UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.black
            ]
            let titleSize = title.size(withAttributes: titleAttrs)
            let titleOrigin = CGPoint(
                x: (pageRect.width - titleSize.width) / 2,
                y: inset
            )
            title.draw(at: titleOrigin, withAttributes: titleAttrs)

            // 3) body text below title
            let df = DateFormatter(); df.dateStyle = .medium
            let lines = [
                String(format: "Payment: $%@ (%.2f%%)", moneyFormatter.string(from: r.periodicPayment as NSNumber) ?? "–", q.annualInterest),
                String(format: "Upfront: $%@", moneyFormatter.string(from: r.upfrontPayment as NSNumber) ?? "–"),
                String(format: "Trade-in: $%@", moneyFormatter.string(from: (q.tradeInValue - q.amountOwed) as NSNumber) ?? "–"),
                String(format: "Before Tax: $%@", moneyFormatter.string(from: r.financedBeforeTax as NSNumber) ?? "–"),
                String(format: "Sales Tax: $%@", moneyFormatter.string(from: r.salesTaxAmount as NSNumber) ?? "–"),
                String(format: "Incl. Tax: $%@", moneyFormatter.string(from: r.financedIncludingTax as NSNumber) ?? "–"),
                String(format: "Interest: $%@", moneyFormatter.string(from: r.totalAccumulatedInterest as NSNumber) ?? "–"),
                String(format: "Total Cost: $%@", moneyFormatter.string(from: r.totalCost as NSNumber) ?? "–"),
                "Pay-off Date: \(df.string(from: r.payOffDate))"
            ]
            let body = lines.joined(separator: "\n\n")
            let bodyAttrs: [NSAttributedString.Key:Any] = [
                .font: UIFont.systemFont(ofSize: 14),
                .foregroundColor: UIColor.black
            ]
            // start just below the title + some padding
            let bodyY = titleOrigin.y + titleSize.height + 20
            let bodyRect = CGRect(
                x: inset,
                y: bodyY,
                width: pageRect.width - inset * 2,
                height: pageRect.height - bodyY - inset * 2
            )
            body.draw(in: bodyRect, withAttributes: bodyAttrs)

            // 4) “Thank you…” centered above the footer
            let thankYou = "Thank you for using AutoCalc: Lease & Finance Calculator"
            let thankAttrs: [NSAttributedString.Key:Any] = [
                .font: UIFont.italicSystemFont(ofSize: 12),
                .foregroundColor: UIColor.darkGray
            ]
            let thankSize = thankYou.size(withAttributes: thankAttrs)
            let thankOrigin = CGPoint(
                x: (pageRect.width - thankSize.width)/2,
                y: pageRect.maxY - inset - thankSize.height - 40
            )
            thankYou.draw(at: thankOrigin, withAttributes: thankAttrs)

            // 5) copyright at bottom-right
            let copyright = "© AutoCalc Lease & Finance"
            let cpAttrs: [NSAttributedString.Key:Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.darkGray
            ]
            let cpSize = copyright.size(withAttributes: cpAttrs)
            let cpOrigin = CGPoint(
                x: pageRect.maxX - cpSize.width - inset,
                y: pageRect.maxY - cpSize.height - inset
            )
            copyright.draw(at: cpOrigin, withAttributes: cpAttrs)
        }
    }
    
    @IBAction func DismissPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
