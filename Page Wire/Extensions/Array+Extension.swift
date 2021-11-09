//
//  Array+Extension.swift
//  Page Wire
//
//  Created by Barkın Özakay on 8.11.2021.
//

import Foundation

extension Array {
    func unique<T: Hashable>(by: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>()
        var ordered = [Element]()
        for value in self {
            if !set.contains(by(value)) {
                set.insert(by(value))
                ordered.append(value)
            }
        }
        return ordered
    }
}
