// LeaseCalculatorViewController.swift

import UIKit

/// Lease input screen — text‐fields for interest & tax.
class LeaseCalculatorViewController: UIViewController, UITextFieldDelegate {
    
    private var pendingLeaseQuote : LeaseQuote?
    private var pendingLeaseResult: LeaseResult?

    // MARK: - IBOutlets
    @IBOutlet weak var VehiclePriceInput: UITextField!
    @IBOutlet weak var LeaseTermInput: UIButton!
    @IBOutlet weak var InterestRateInput: UITextField!
    @IBOutlet weak var DownPaymentInput: UITextField!
    @IBOutlet weak var SalesTaxInput: UITextField!
    @IBOutlet weak var PaymentFrequencyInput: UIButton!
    @IBOutlet weak var TradeInValueInput: UITextField!
    @IBOutlet weak var AmountOwedInput: UITextField!
    @IBOutlet weak var RebatesInput: UITextField!
    @IBOutlet weak var AllOtherFeesInput: UITextField!
    @IBOutlet weak var ResidualInput: UIButton!
    @IBOutlet weak var StartDateInput: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ─── DEFAULTS ───────────────────────────────
        VehiclePriceInput.text = "44000"
        LeaseTermInput.setTitle("48", for: .normal)
        InterestRateInput.text = "6.59"
        SalesTaxInput.text     = "13"
        DownPaymentInput.text  = "0"
        TradeInValueInput.text = "0"
        AmountOwedInput.text   = "0"
        RebatesInput.text      = "0"
        AllOtherFeesInput.text = "0"
        PaymentFrequencyInput.setTitle("12", for: .normal)
        ResidualInput.setTitle("48%", for: .normal)
        // ────────────────────────────────────────────

        configureLeaseTermMenu()
        configurePaymentFrequencyMenu()
        configureResidualMenu()

        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        [ VehiclePriceInput,
          InterestRateInput,
          DownPaymentInput,
          SalesTaxInput,
          TradeInValueInput,
          AmountOwedInput,
          RebatesInput,
          AllOtherFeesInput
        ].forEach { $0?.delegate = self }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - Actions

    @IBAction func CalculatePressed(_ sender: UIButton) {
        let quote = LeaseQuote(
          vehiclePrice:    InputParser.parseDouble(from: VehiclePriceInput, defaultValue: 0),
          downPayment:     InputParser.parseDouble(from: DownPaymentInput,     defaultValue: 0),
          tradeInValue:    InputParser.parseDouble(from: TradeInValueInput,    defaultValue: 0),
          amountOwed:      InputParser.parseDouble(from: AmountOwedInput,      defaultValue: 0),
          rebates:         InputParser.parseDouble(from: RebatesInput,         defaultValue: 0),
          allOtherFees:    InputParser.parseDouble(from: AllOtherFeesInput,    defaultValue: 0),
          residualPercent: InputParser.parsePercent(from: ResidualInput,      defaultValue: 0),
          leaseTermMonths: InputParser.parseInt(from: LeaseTermInput,         defaultValue: 0),
          annualInterest:  InputParser.parsePercent(from: InterestRateInput,  defaultValue: 0),
          salesTaxPercent: InputParser.parsePercent(from: SalesTaxInput,      defaultValue: 0),
          paymentsPerYear: InputParser.parseInt(from: PaymentFrequencyInput, defaultValue: 0),
          startDate:       StartDateInput.date
        )

        let result = LeaseCalculator.calculate(quote: quote)
        pendingLeaseQuote  = quote
        pendingLeaseResult = result
        performSegue(withIdentifier: "ShowLeaseResults", sender: self)
    }

    // MARK: - Segue wiring

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowLeaseResults",
           let dest = segue.destination as? LeaseResultsViewController,
           let q = pendingLeaseQuote,
           let r = pendingLeaseResult
        {
            dest.leaseQuote  = q
            dest.leaseResult = r
        }
    }

    // MARK: - Dropdowns

    private func configureLeaseTermMenu() {
        let terms = stride(from: 12, through: 96, by: 12).map { term in
            UIAction(title: "\(term)") { [weak self] action in
                self?.LeaseTermInput.setTitle(action.title, for: .normal)
            }
        }
        LeaseTermInput.menu = UIMenu(title: "Lease Term", children: terms)
        LeaseTermInput.showsMenuAsPrimaryAction     = true
        LeaseTermInput.changesSelectionAsPrimaryAction = true
    }

    private func configurePaymentFrequencyMenu() {
        let freqs = [12, 24, 26].map { f in
            UIAction(title: "\(f)") { [weak self] action in
                self?.PaymentFrequencyInput.setTitle(action.title, for: .normal)
            }
        }
        PaymentFrequencyInput.menu = UIMenu(title: "Payments/Year", children: freqs)
        PaymentFrequencyInput.showsMenuAsPrimaryAction     = true
        PaymentFrequencyInput.changesSelectionAsPrimaryAction = true
    }

    private func configureResidualMenu() {
        let percents = (1...100).map { p in
            UIAction(title: "\(p)%") { [weak self] action in
                self?.ResidualInput.setTitle(action.title, for: .normal)
            }
        }
        ResidualInput.menu = UIMenu(title: "Residual (%)", children: percents)
        ResidualInput.showsMenuAsPrimaryAction     = true
        ResidualInput.changesSelectionAsPrimaryAction = true
    }
}
