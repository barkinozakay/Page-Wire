//
//  BookPricingModels.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 11.05.2021.
//

import Foundation

enum BookPricingSite: String, CaseIterable {
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

struct BookDataModel: Equatable {
    var site: BookPricingSite?
    var price: String?
    var discount: String?
    var url: String?
}


