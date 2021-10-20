//
//  String+Extensions.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 28.03.2021.
//

import Foundation

extension String {
    
    var isAlphaNumeric: Bool {
        let turkishCharacters: [String] = ["ğıöşü"]
        return !isEmpty && range(of: "[^a-zA-Z0-9\(turkishCharacters) ]", options: .regularExpression) == nil
    }
    
    mutating func getAlphaNumericValue() {
        let unsafeChars = CharacterSet.alphanumerics.inverted
        self  = self.components(separatedBy: unsafeChars).joined(separator: " ")
    }
    
    func removeDiacritics() -> String {
        return self.folding(options: .diacriticInsensitive, locale: .current).replacingOccurrences(of: "ı", with: "i")
    }
    
    mutating func trimmingAllSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) {
        self = components(separatedBy: characterSet).joined()
    }

    func toDouble() -> Double? {
        if self.contains(",") {
            return NumberFormatter().number(from: self.components(separatedBy: ",").joined(separator: "."))?.doubleValue
        } else {
            return NumberFormatter().number(from: self)?.doubleValue
        }
    }
    
    func addZeroToEnd() -> String? {
        if let count = self.components(separatedBy: ",").last?.count, count == 1 {
            var newStr = self
            newStr.append("0")
            return newStr
        }
        return self
    }
    
}

extension DefaultStringInterpolation {
    mutating func appendInterpolation<T>(_ optional: T?) {
        appendInterpolation(String(describing: optional))
    }
}
