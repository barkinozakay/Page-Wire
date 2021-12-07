//
//  FavoriteBooksManager.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 22.04.2021.
//

import Foundation
import FirebaseFirestore
import FirebaseDatabase

enum FavoriteBookAction {
    case add
    case remove
}

class FavoriteBooksManager {
    
    private init() {}
    
    static let shared = FavoriteBooksManager()
    
    private let firestore = Firestore.firestore()
    private let realtimeDatabase = Database.database().reference()
    
    // TODO: Maybe async w/delegate?
    func getFavoritedBooks(_ completion: @escaping ([BookModel]) -> Void) {
        guard let userID = appDel.userID else { return completion([]) }
        let docRef = firestore.collection("Favorites").document("Users").collection(userID)
        var favoritedBooks: [BookModel] = []
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    guard let favoritedBook = self.convertBookDataToModel(data: document.data()) else { continue }
                    favoritedBooks.append(favoritedBook)
                }
            }
            completion(favoritedBooks)
        }
    }
    
    private func convertBookDataToModel(data: [String: Any]) -> BookModel? {
        let name = data["name"] as? String ?? ""
        let author = data["author"] as? String ?? ""
        let publisher = data["publisher"] as? String ?? ""
        let genre = data["genre"] as? String ?? ""
        let pages = data["pages"] as? Int ?? 0
        let isbn = data["isbn"] as? Int ?? 0
        let isFavorited = data["isFavorited"] as? Bool ?? false
        let siteData = data["siteData"] as? [BookSiteData] ?? []
        let artwork = data["artwork"] as? String ?? ""
        let info = data["info"] as? String ?? ""
        let otherPublishers = data["otherPublishers"] as? [String : Int] ?? [:]
        return BookModel(name: name, author: author, publisher: publisher, genre: genre, pages: pages, isbn: isbn, isFavorited: isFavorited, siteData: siteData, artwork: artwork, info: info, otherPublishers: otherPublishers)
    }
    
    func addBookToFavorites(_ book: BookModel) {
        guard let userID = appDel.userID, !book.isbn.description.isEmpty else { return }
        let isbn = book.isbn.description
        let docRef = firestore.collection("Favorites").document("Users").collection(userID).document("\(isbn)")
        let bookData = book.dictionary ?? [:]
        docRef.setData(bookData, merge: true) { error in
            guard error == nil else { return print("Could not save book data.") }
            print("Book with isbn: \(isbn) saved to Firestore successfully.")
        }
    }
    
    func removeBookFromFavorites(_ book: BookModel) {
        guard let userID = appDel.userID, !book.isbn.description.isEmpty else { return }
        let isbn = book.isbn.description
        let docRef = firestore.collection("Favorites").document("Users").collection(userID).document("\(isbn)")
        docRef.delete { error in
            guard error == nil else { return print("Could not delete book data.") }
            print("Book with isbn: \(isbn) deleted from Firestore successfully.")
        }
    }
    
    func appendAllBooksToFirebase(_ books: [BookModel]) {
        for book in books {
            guard let bookData = book.dictionary else { continue }
            let isbn = book.isbn.description
            realtimeDatabase.child("Books").child(isbn).setValue(bookData) { (error: Error?, ref: DatabaseReference) in
                if let error = error {
                    print("Data could not be saved: \(error).")
                } else {
                    print("Book with isbn: \(isbn) saved to Realtime Database successfully.")
                }
            }
        }
    }
}
