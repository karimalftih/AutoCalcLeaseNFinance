// Model/SavedQuote.swift
import Foundation

public enum QuoteType: String {
  case finance
  case lease
}

public struct SavedQuote {
  public let type: QuoteType
  public let vehiclePrice: Double
  public let termMonths: Int
  public let paymentsPerYear: Int
  public let payment: Double
  public let interestRate: Double
  public let downPayment: Double
  public let salesTaxPercent: Double
  public let totalCost: Double
  public let dateSaved: Date

  public init(
    type: QuoteType,
    vehiclePrice: Double,
    termMonths: Int,
    paymentsPerYear: Int,
    payment: Double,
    interestRate: Double,
    downPayment: Double,
    salesTaxPercent: Double,
    totalCost: Double,
    dateSaved: Date = Date()
  ) {
    self.type           = type
    self.vehiclePrice   = vehiclePrice
    self.termMonths     = termMonths
    self.paymentsPerYear = paymentsPerYear
    self.payment        = payment
    self.interestRate   = interestRate
    self.downPayment    = downPayment
    self.salesTaxPercent = salesTaxPercent
    self.totalCost      = totalCost
    self.dateSaved      = dateSaved
  }
}
