// Services/QuoteStore.swift
import Foundation

public class QuoteStore {
  public static let shared = QuoteStore()
  private init() {}

  /// Read-only externally
  public private(set) var quotes: [SavedQuote] = []

  /// Append a new quote
  public func add(_ quote: SavedQuote) {
    quotes.append(quote)
  }

  /// Remove at index
  public func remove(at index: Int) {
    guard quotes.indices.contains(index) else { return }
    quotes.remove(at: index)
  }
}
