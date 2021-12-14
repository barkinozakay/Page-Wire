//
//  BookModels.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 31.03.2021.
//

import Foundation

struct BookList: Codable, Equatable {
    let books: [BookModel]
}

struct BookModel: Codable, Equatable {
    var name: String?
    var author: String?
    var publisher: String?
    var genre: String?
    var pages: Int?
    var isbn: Int?
    var isFavorited: Bool?
    var siteData: [BookSiteData]?
    var artwork: String?
    var info: String?
    var otherPublishers: [String: Int]?
}

enum BookSearchType: String {
    case title = "title"
    case author = "author"
}

struct BookSiteData: Codable, Equatable {
    var site: BookSite?
    var url: String?
    var price: Double?
    var discount: String?
}

enum BookSite: String, CaseIterable, Codable {
    case amazon = "Amazon"
    case dnr = "DR"
    case eganba = "Eganba"
    case idefix = "İdefix"
    case istanbul_kitapcisi = "İstanbul Kitapçısı"
    case kidega = "Kidega"
    case kitapkoala = "Kitap Koala"
    case kitapsepeti = "Kitap Sepeti"
    case kitapyurdu = "Kitap Yurdu"
    case pandora = "Pandora"
    case ucuz_kitap_al = "Ucuz Kitap Al"
}
