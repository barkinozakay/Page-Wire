//
//  FavoriteBooksManager.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 22.04.2021.
//

import Foundation
import FirebaseFirestore

class FavoriteBooksManager {
    
    private init() {}
    
    static let shared = FavoriteBooksManager()
    
    func getFavorites() -> [BookModel] {
        var userData: [BookModel]!
        if let data = UserDefaults.standard.value(forKey: Keys.favorites) as? Data {
            userData = try? PropertyListDecoder().decode([BookModel].self, from: data)
            return userData ?? []
        } else {
            return userData ?? []
        }
    }
    
    func addToFavorites(_ book: BookModel) {
        var favorites = getFavorites()
        var newBook = book
        newBook.isFavorited = true
        favorites.append(newBook)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(favorites), forKey: Keys.favorites)
    }
    
    func removeFromFavorites(_ book: BookModel) {
        var favorites = getFavorites()
        var newBook = book
        newBook.isFavorited = true
        guard let index = favorites.firstIndex(of: newBook) else { return }
        favorites.remove(at: index)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(favorites), forKey: Keys.favorites)
    }
    
    // MARK: - Firebase Firestorm
    func addBookToFavorites(_ book: BookModel) {
        guard let uid = appDel.userID, !book.isbn.description.isEmpty else { return }
        let isbn = book.isbn.description
        let database = Firestore.firestore()
        let docRef = database.document("Page Wire/Users/\(uid)/\(isbn)")
        let bookData = book.dictionary ?? [:]
        docRef.setData(bookData, merge: true) { error in
            guard error == nil else { return print("Could not save book data.") }
            print("Book with isbn: \(isbn) saved to database successfully.")
        }
    }
    
    func removeBookFromFavorites(_ book: BookModel) {
        guard let uid = appDel.userID, !book.isbn.description.isEmpty else { return }
        let firestore = Firestore.firestore()
        let isbn = book.isbn.description
        let docRef = firestore.document("Page Wire/Users/\(uid)/\(isbn)")
        docRef.delete { error in
            guard error == nil else { return print("Could not delete book data.") }
            print("Book with isbn: \(isbn) deleted from database successfully.")
        }
    }
}
