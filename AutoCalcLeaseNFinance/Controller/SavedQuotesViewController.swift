import UIKit

class SavedQuotesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Data
    private var quotes: [SavedQuote] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hook up table
        tableView.dataSource = self
        tableView.delegate   = self
        
        // dynamic row height
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        
        // hide empty separators
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // reload from the central store
        quotes = QuoteStore.shared.quotes
        tableView.reloadData()
    }
    
    // helper to turn 12→"M", 24→"SM", 26→"B/W", else just the number
    private func frequencyAbbreviation(_ paymentsPerYear: Int) -> String {
        switch paymentsPerYear {
        case 12: return "Monthly"
        case 24: return "Semi-Monthly"
        case 26: return "Bi-Weekly"
        default: return "\(paymentsPerYear)"
        }
    }
}

// MARK: - UITableViewDataSource
extension SavedQuotesViewController: UITableViewDataSource {
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }

    func tableView(_ tv: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Make sure your prototype cell is Style=Subtitle, Identifier="QuoteCell"
        let cell  = tv.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        let q     = quotes[indexPath.row]
        
        // 1) Title: "$44000 - 84 Month Financing Quote"
        let vp = Int(round(q.vehiclePrice))
        let tp = q.termMonths
        let typeString = q.type == .finance ? "Financing" : "Leasing"
        cell.textLabel?.text = "$\(vp) - \(tp) Month \(typeString) Quote"
        
        // 2) Subtitle: "$333 B/W - 6% Interest - $1000 Down - 8.25% Tax Included"
        let pay    = Int(round(q.payment))
        let freq   = frequencyAbbreviation(q.paymentsPerYear)
        let ir     = String(format: "%.2f%%", q.interestRate)
        let down   = Int(round(q.downPayment))
        let taxPct = String(format: "%.2f%%", q.salesTaxPercent)
        cell.detailTextLabel?.text =
          "$\(pay) \(freq) - \(ir) Interest - $\(down) Down - \(taxPct) Tax Included"
        
        // allow multi-line subtitle
        cell.detailTextLabel?.numberOfLines = 0
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping
        
        return cell
    }
    
    // enable swipe-to-delete
    func tableView(_ tv: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        // remove from store...
        QuoteStore.shared.remove(at: indexPath.row)
        // ...update our array & UI
        quotes.remove(at: indexPath.row)
        tv.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - UITableViewDelegate
extension SavedQuotesViewController: UITableViewDelegate {
    func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        // (optionally) show details here
    }
}
