import UIKit

enum InputParser {
    /// Reads a Double from a text field, or returns & fills the default if empty/invalid.
    static func parseDouble(from field: UITextField, defaultValue: Double) -> Double {
        if let txt = field.text, let val = Double(txt) { return val }
        field.text = "\(defaultValue)"
        return defaultValue
    }

    /// Reads an Int from a button’s title, or returns & sets the default if invalid.
    static func parseInt(from button: UIButton, defaultValue: Int) -> Int {
        if let t = button.currentTitle, let v = Int(t) { return v }
        button.setTitle("\(defaultValue)", for: .normal)
        return defaultValue
    }

    /// Reads a percentage (as a Double) from a text field ("5.25"), defaulting to 0 if blank/invalid.
    static func parsePercent(from field: UITextField, defaultValue: Double) -> Double {
        if let txt = field.text, let val = Double(txt) { return val }
        field.text = "\(defaultValue)"
        return defaultValue
    }

    /// Reads a percentage from a button’s title ("5.25%"), defaulting to 0 if blank/invalid.
    static func parsePercent(from button: UIButton, defaultValue: Double) -> Double {
        if let t = button.currentTitle?
             .trimmingCharacters(in: CharacterSet(charactersIn: "%")),
           let v = Double(t) {
            return v
        }
        button.setTitle("\(defaultValue)%", for: .normal)
        return defaultValue
    }
}
