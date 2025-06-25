// FinanceCalculatorViewController.swift

import UIKit

/// Finance input screen — now with text‐fields for interest & tax.
class FinanceCalculatorViewController: UIViewController, UITextFieldDelegate {
    
    private var pendingQuote: FinanceQuote?
    private var pendingResult: FinanceResult?

    // MARK: - IBOutlets
    @IBOutlet weak var VehiclePriceInput: UITextField!
    @IBOutlet weak var LoanTermInput: UIButton!
    @IBOutlet weak var InterestRateInput: UITextField!
    @IBOutlet weak var DownPaymentInput: UITextField!
    @IBOutlet weak var SalesTaxInput: UITextField!
    @IBOutlet weak var PaymentFrequencyInput: UIButton!
    @IBOutlet weak var TradeInValueInput: UITextField!
    @IBOutlet weak var AmountOwedInput: UITextField!
    @IBOutlet weak var RebatesInput: UITextField!
    @IBOutlet weak var AllOtherFeesInput: UITextField!
    @IBOutlet weak var StartDateInput: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        // ─── DEFAULTS ───────────────────────────────
        VehiclePriceInput.text = "44000"
        LoanTermInput.setTitle("84", for: .normal)
        InterestRateInput.text = "6"
        SalesTaxInput.text     = "13"
        DownPaymentInput.text  = "0"
        TradeInValueInput.text = "0"
        AmountOwedInput.text   = "0"
        RebatesInput.text      = "0"
        AllOtherFeesInput.text = "0"
        PaymentFrequencyInput.setTitle("12", for: .normal)
        // ────────────────────────────────────────────

        configureLoanTermMenu()
        configurePaymentFrequencyMenu()

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
        let quote = FinanceQuote(
          vehiclePrice:    InputParser.parseDouble(from: VehiclePriceInput, defaultValue: 0),
          downPayment:     InputParser.parseDouble(from: DownPaymentInput,     defaultValue: 0),
          tradeInValue:    InputParser.parseDouble(from: TradeInValueInput,    defaultValue: 0),
          amountOwed:      InputParser.parseDouble(from: AmountOwedInput,      defaultValue: 0),
          rebates:         InputParser.parseDouble(from: RebatesInput,         defaultValue: 0),
          allOtherFees:    InputParser.parseDouble(from: AllOtherFeesInput,    defaultValue: 0),
          loanTermMonths:  InputParser.parseInt(from: LoanTermInput,          defaultValue: 0),
          annualInterest:  InputParser.parsePercent(from: InterestRateInput,  defaultValue: 0),
          salesTaxPercent: InputParser.parsePercent(from: SalesTaxInput,      defaultValue: 0),
          paymentsPerYear: InputParser.parseInt(from: PaymentFrequencyInput, defaultValue: 0),
          startDate:       StartDateInput.date
        )

        let result = FinanceCalculator.calculate(quote: quote)
        pendingQuote  = quote
        pendingResult = result
        performSegue(withIdentifier: "ShowFinanceResults", sender: self)
    }

    // MARK: - Segue wiring

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFinanceResults",
           let dest = segue.destination as? FinanceResultsViewController,
           let q = pendingQuote,
           let r = pendingResult
        {
            dest.financeQuote  = q
            dest.financeResult = r
        }
    }

    // MARK: - Dropdown menus

    private func configureLoanTermMenu() {
        let terms = stride(from: 12, through: 96, by: 12).map { term in
            UIAction(title: "\(term)") { [weak self] action in
                self?.LoanTermInput.setTitle(action.title, for: .normal)
            }
        }
        LoanTermInput.menu = UIMenu(title: "Loan Term (months)", children: terms)
        LoanTermInput.showsMenuAsPrimaryAction     = true
        LoanTermInput.changesSelectionAsPrimaryAction = true
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
}
