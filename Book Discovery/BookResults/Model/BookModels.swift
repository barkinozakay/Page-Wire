//
//  BookModels.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 31.03.2021.
//

import Foundation

struct BookList: Codable, Equatable {
    let book: [BookModel]
}

struct BookModel: Codable, Equatable {
    let name: String
    let author: String
    let publisher: String
    let genre: String
    let pages: Int
    let isbn: Int
}
