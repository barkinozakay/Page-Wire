//
//  Notification+Extensions.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 11.05.2021.
//

import Foundation

extension Notification.Name {
    static let removeBookFromFavorites = Notification.Name.init(rawValue: "removeBookFromFavorites")
    static let changeBookFavoriteStateFromDetail = Notification.Name.init(rawValue: "changeBookFavoriteStateFromDetail")
}

