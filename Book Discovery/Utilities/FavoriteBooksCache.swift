//
//  FavoriteBooksCache.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 22.04.2021.
//

import Foundation

struct FavoriteBooksCache {
    
    static let key = "favorites"
    
    static func getFavorites() -> [BookModel] {
        var userData: [BookModel]!
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            userData = try? PropertyListDecoder().decode([BookModel].self, from: data)
            return userData ?? []
        } else {
            return userData ?? []
        }
    }
    
    static func addToFavorites(_ book: BookModel) {
        var favorites = getFavorites()
        var newBook = book
        newBook.isFavorited = true
        favorites.append(newBook)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(favorites), forKey: key)
    }
    
    static func removeFromFavorites(_ book: BookModel) {
        var favorites = getFavorites()
        var newBook = book
        newBook.isFavorited = true
        guard let index = favorites.firstIndex(of: newBook) else { return }
        favorites.remove(at: index)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(favorites), forKey: key)
    }
}
