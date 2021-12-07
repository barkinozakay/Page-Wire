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
        var favoritedBook: BookModel?
        favoritedBook?.name = data["name"] as! String
        favoritedBook?.author = data["author"] as! String
        favoritedBook?.publisher = data["publisher"] as! String
        favoritedBook?.genre = data["genre"] as! String
        favoritedBook?.pages = data["pages"] as! Int
        favoritedBook?.isbn = data["isbn"] as! Int
        favoritedBook?.isFavorited = data["isFavorited"] as? Bool
        favoritedBook?.siteData = data["siteData"] as? [BookSiteData]
        favoritedBook?.artwork = data["artwork"] as? String
        favoritedBook?.info = data["info"] as? String
        favoritedBook?.otherPublishers = data["otherPublishers"] as? [String : Int]
        return favoritedBook
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
