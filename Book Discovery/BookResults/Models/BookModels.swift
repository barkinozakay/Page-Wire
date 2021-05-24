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
    let name: String
    let author: String
    let publisher: String
    let genre: String
    let pages: Int
    let isbn: Int
    var isFavorited: Bool?
    var siteData: [BookSiteData]?
    var artwork: String?
}

enum BookSearchType: String {
    case title = "title"
    case author = "author"
}

struct BookSiteData: Codable, Equatable {
    var site: BookSite?
    var url: String?
    var price: [String: String]?
}

enum BookSite: String, CaseIterable, Codable {
    case amazon = "Amazon"
    case bkmkitap = "BKM Kitap"
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
