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
    
    func checkForFavoritedBook(_ favBook: BookModel?, _ completion: @escaping (Bool) -> Void) {
        guard let book = favBook else { return completion(false) }
        guard let userID = appDel.userID, !book.isbn.description.isEmpty else { return completion(false) }
        let docRef = firestore.collection("Favorites").document("Users").collection(userID).document(book.isbn.description)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                completion(true)
            } else {
                print("Document does not exist")
                completion(false)
            }
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
    
    func addBookToFavorites(_ book: BookModel, _ completion: @escaping (Bool) -> Void) {
        guard let userID = appDel.userID, !book.isbn.description.isEmpty else { return completion(false) }
        let isbn = book.isbn.description
        let docRef = firestore.collection("Favorites").document("Users").collection(userID).document("\(isbn)")
        let bookData = book.dictionary ?? [:]
        docRef.setData(bookData, merge: true) { error in
            if error == nil {
                print("Book with isbn: \(isbn) saved to Firestore successfully.")
                completion(true)
            } else {
                print("Could not save book data.")
                return completion(false)
            }
        }
    }
    
    func removeBookFromFavorites(_ book: BookModel, _ completion: @escaping (Bool) -> Void) {
        guard let userID = appDel.userID, !book.isbn.description.isEmpty else { return completion(false) }
        let isbn = book.isbn.description
        let docRef = firestore.collection("Favorites").document("Users").collection(userID).document("\(isbn)")
        docRef.delete { error in
            if error == nil {
                print("Book with isbn: \(isbn) deleted from Firestore successfully.")
                completion(true)
            } else {
                print("Could not delete book data.")
                return completion(false)
            }
        }
    }
    
    func appendAllBooksToFirebase(_ books: [BookModel]) {
        // TODO: This works actually :)
//        realtimeDatabase.child("Books").child("isbn").setValue(["bisi": 5]) { error, databaseRef in
//            if let error = error {
//                print("Data could not be saved: \(error).")
//            } else {
//                print("Book with isbn: 123 saved to Realtime Database successfully.")
//            }
//        }
        
//        var counter = 0
//        for book in books {
//            guard counter <= 10 else { return }
//            guard let bookData = book.dictionary else { continue }
//            let isbn = book.isbn.description
//            realtimeDatabase.child("Books").child("\(isbn)").setValue(bookData) { error, databaseRef in
//                if let error = error {
//                    print("Data could not be saved: \(error).")
//                } else {
//                    print("Book with isbn: \(isbn) saved to Realtime Database successfully.")
//                }
//                counter += 1
//            }
//        }
    }
}
