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
}
