import Foundation

/// Encapsulates all input data for a finance calculation.
public struct FinanceQuote {
  public let vehiclePrice:   Double
  public let downPayment:    Double
  public let tradeInValue:   Double
  public let amountOwed:     Double
  public let rebates:        Double
  public let allOtherFees:   Double
  public let loanTermMonths: Int
  public let annualInterest: Double  // e.g. 8.90 for 8.90%
  public let salesTaxPercent: Double // e.g. 13.0 for 13%
  public let paymentsPerYear: Int    // e.g. 12, 24, 26
  public let startDate:      Date
}

/// Holds the results of a finance calculation.
public struct FinanceResult {
  public let financedBeforeTax:        Double
  public let salesTaxAmount:           Double
  public let financedIncludingTax:     Double
  public let periodicPayment:          Double
  public let totalAccumulatedInterest: Double
  public let totalCost:                Double
  public let upfrontPayment:           Double
  public let payOffDate:               Date
}

/// Performs all finance calculations based on a FinanceQuote.
public enum FinanceCalculator {
  public static func calculate(quote: FinanceQuote) -> FinanceResult {
    // 1) Net trade-in
    let netTradeIn = quote.tradeInValue - quote.amountOwed

    // 2) Principal before tax
    let financedBeforeTax =
      quote.vehiclePrice
      + quote.allOtherFees
      - quote.downPayment
      - quote.rebates
      - netTradeIn

    // 3) Sales tax on principal
    let salesTaxAmount = financedBeforeTax * quote.salesTaxPercent / 100

    // 4) Total amount financed
    let financedIncludingTax = financedBeforeTax + salesTaxAmount

    // 5) Total number of payments (integer arithmetic)
    let totalPayments = quote.loanTermMonths * quote.paymentsPerYear / 12
    let n = max(totalPayments, 1)

    // 6) Periodic interest rate
    let r = (quote.annualInterest / 100) / Double(quote.paymentsPerYear)

    // 7) Periodic payment via annuity formula
    let payment: Double
    if r == 0 {
      payment = financedIncludingTax / Double(n)
    } else {
      // A = P * r / (1 − (1+r)^−n)
      let denom = 1 - pow(1 + r, -Double(n))
      payment = financedIncludingTax * r / denom
    }

    // 8) Total interest
    let totalInterest = payment * Double(n) - financedIncludingTax

    // 9) Upfront payment is just the down payment
    let upfront = quote.downPayment

    // 10) Total cost out-of-pocket
    let totalCost = upfront + payment * Double(n)

    // 11) Payoff date
    let payOffDate = Calendar.current.date(
      byAdding: .month,
      value: quote.loanTermMonths,
      to: quote.startDate
    ) ?? quote.startDate

    return FinanceResult(
      financedBeforeTax:        financedBeforeTax,
      salesTaxAmount:           salesTaxAmount,
      financedIncludingTax:     financedIncludingTax,
      periodicPayment:          payment,
      totalAccumulatedInterest: totalInterest,
      totalCost:                totalCost,
      upfrontPayment:           upfront,
      payOffDate:               payOffDate
    )
  }
}
