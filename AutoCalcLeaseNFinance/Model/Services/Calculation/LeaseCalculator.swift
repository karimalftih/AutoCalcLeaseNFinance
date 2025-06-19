import Foundation

/// Input data for a lease calculation.
public struct LeaseQuote {
  public let vehiclePrice:   Double
  public let downPayment:    Double
  public let tradeInValue:   Double
  public let amountOwed:     Double
  public let rebates:        Double
  public let allOtherFees:   Double
  public let residualPercent: Double
  public let leaseTermMonths: Int
  public let annualInterest:  Double
  public let salesTaxPercent: Double
  public let paymentsPerYear: Int
  public let startDate:       Date
}

/// Results returned from a lease calculation.
public struct LeaseResult {
  public let periodicPayment:          Double
  public let upfrontPayment:           Double
  public let leasedBeforeTax:          Double
  public let salesTaxAmount:           Double
  public let leasedIncludingTax:       Double
  public let totalAccumulatedInterest: Double
  public let totalLeaseCost:           Double
  public let residualValueAmount:      Double
  public let residualValueIncludingTax: Double
  public let payOffDate:               Date
}

/// Performs lease calculations.
public enum LeaseCalculator {
  public static func calculate(quote: LeaseQuote) -> LeaseResult {
    // 1) Net trade-in
    let netTradeIn = quote.tradeInValue - quote.amountOwed

    // 2) Capitalized Cost (cap cost)
    let capCost =
      quote.vehiclePrice
      + quote.allOtherFees
      - quote.downPayment
      - quote.rebates
      - netTradeIn

    // 3) Residual dollar amount at end
    let residualAmount = quote.vehiclePrice * quote.residualPercent / 100

    // 4) Depreciation portion (cap cost minus residual)
    let depreciationPortion = capCost - residualAmount

    // 5) Total payments count
    let totalPayments = quote.leaseTermMonths * quote.paymentsPerYear / 12
    let n = max(totalPayments, 1)

    // 6) Sales tax on the depreciation portion
    let salesTaxAmount = depreciationPortion * quote.salesTaxPercent / 100

    // 7) Fees per period
    let depreciationFeePerPeriod = depreciationPortion / Double(n)
    let taxFeePerPeriod         = salesTaxAmount   / Double(n)

    // 8) Finance (money) fee per period:
    //    average balance * periodic interest rate
    let r = (quote.annualInterest / 100) / Double(quote.paymentsPerYear)
    let averageBalance = (capCost + residualAmount) / 2
    let financeFeePerPeriod = averageBalance * r

    // 9) Combined periodic payment
    let periodicPayment =
      depreciationFeePerPeriod
      + taxFeePerPeriod
      + financeFeePerPeriod

    // 10) Total accumulated interest
    let totalInterest = financeFeePerPeriod * Double(n)

    // 11) Upfront payment
    let upfront = quote.downPayment

    // 12) Total lease cost
    let totalLeaseCost = upfront + periodicPayment * Double(n)

    // 13) Pay-off (lease end) date
    let payOffDate = Calendar.current.date(
      byAdding: .month,
      value: quote.leaseTermMonths,
      to: quote.startDate
    ) ?? quote.startDate

    // 14) Residual Value Including Tax
    let residualValueIncludingTax =
      residualAmount * (1 + quote.salesTaxPercent / 100)

    return LeaseResult(
      periodicPayment:          periodicPayment,
      upfrontPayment:           upfront,
      leasedBeforeTax:          depreciationPortion,
      salesTaxAmount:           salesTaxAmount,
      leasedIncludingTax:       depreciationPortion + salesTaxAmount,
      totalAccumulatedInterest: totalInterest,
      totalLeaseCost:           totalLeaseCost,
      residualValueAmount:      residualAmount,
      residualValueIncludingTax: residualValueIncludingTax,
      payOffDate:               payOffDate
    )
  }
}
