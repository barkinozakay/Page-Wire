//
//  Double+Extension.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 24.05.2021.
//

import Foundation

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
