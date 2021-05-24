//
//  BookDataViewModel.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 20.05.2021.
//

import Foundation
import SwiftSoup

protocol BookDataFromSiteDelegate: class {
    func getBookDataForSites(_ data: [BookSiteData]?, _ isFinished: Bool)
}

protocol BookArtworkFromSiteDelegate: class {
    func getBookArtworkUrl(_ artwork: String, _ index: Int)
}

class BookDataViewModel {
    
    private var book: BookModel?
    private var books: [BookModel] = []
    
    private var httpsPrefix: String = "https://www."
    private var googleSearchQueryPrefix: String = "https://www.google.com.tr/search?q="
    
    
    weak var siteDataDelegate: BookDataFromSiteDelegate?
    weak var artworkDelegate: BookArtworkFromSiteDelegate?
    
    init(book: BookModel) {
        self.book = book
    }
    
    init(books: [BookModel]) {
        self.books = books
    }
    
    func getBookDataForSites() {
        guard let name = book?.name, let author = book?.author else { return }
        var bookSiteDataList = book?.siteData
        bookSiteDataList = []
        var callCounter = 0
        var totalCallCount = BookSite.allCases.count
        for site in BookSite.allCases {
            let searchQuery = prepareQuery("\(name) \(author)")
            guard let siteQueryPrefix = selectQueryForSite(site),
                  !siteQueryPrefix.isEmpty else {
                totalCallCount -= 1
                continue
            }
            getHtmlFromSearchQuery(siteQueryPrefix + searchQuery) { (response) in
                guard let html = response, !html.isEmpty else { return }
                guard let bookLink = self.getBookLinkForSite(site, html), !bookLink.isEmpty else { return }
                self.startNewSessionAsync(URL(string: bookLink)) { (response) in
                    callCounter += 1
                    guard let responseHtml = response else { return }
                    let isFinished = callCounter == totalCallCount ? true : false
                    if site == .idefix {            // CHANGE
                        let artwork: String? = self.getArtwork(responseHtml)
                        self.book?.artwork = artwork
                    }
                    if let price = self.decideToGetSiteData(site, responseHtml) {
                        bookSiteDataList?.append(BookSiteData(site: site, url: bookLink, price: price))
                    }
                    self.siteDataDelegate?.getBookDataForSites(bookSiteDataList, isFinished)
                }
            }
        }
        self.book?.siteData = bookSiteDataList
    }
    
    private func prepareQuery(_ query: String) -> String {
        var newQuery = query
        newQuery.getAlphaNumericValue()
        newQuery = newQuery.removeDiacritics().split(separator: " ").joined(separator: "+")
        return newQuery
    }
    
    private func selectQueryForSite(_ site: BookSite) -> String? {
        switch site {
            case .amazon:
                return httpsPrefix + "amazon.com.tr/s?k="
            case .bkmkitap:
                return httpsPrefix + "bkmkitap.com/arama?q="
            case .dnr:
                return httpsPrefix + "dr.com.tr/search?q="
            case .kitapyurdu:
                return httpsPrefix + "kitapyurdu.com/index.php?route=product/search&filter_name="
            default:
                return nil
        }
    }
    
    private func getHtmlFromSearchQuery(_ query: String, _ comp: @escaping (String?) -> ()) {
        guard !query.isEmpty else { return }
        var html: String?
        let url = URL(string: query)
        startNewSessionAsync(url) { (content) in
            html = content
            comp(html)
        }
    }
    
    private func startNewSessionAsync(_ url: URL?, delay: Double = 0.0, _ comp: @escaping (String?) -> ()) {
        guard let myUrl = url else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            URLSession.shared.dataTask(with: myUrl) { (data, response, error) in
                if error != nil {
                    print(error!)
                } else {
                    comp(String(decoding: data!, as: UTF8.self))
                }
            }.resume()
        }
    }
    
//    func getBookArtworkUrl() {
//        var artwork: String = ""
//        for index in 0..<books.count {
//            let name = books[index].name
//            let publisher = books[index].publisher
//            let site = BookSite.idefix
//            let query = prepareQuery("\(name) \(publisher) \(site.rawValue) satın al")
//            getHtmlFromSearchQuery(query) { (response) in
//                guard let html = response, !html.isEmpty else { return }
//                guard let link = self.getLink(html, site), !link.isEmpty else { return }
//                let url = URL(string: link)
//                self.startNewSessionAsync(url, delay: 0.1) { (content) in
//                    guard let siteHtml = content, !siteHtml.isEmpty else { return }
//                    artwork = self.getArtwork(siteHtml) ?? ""
//                    self.books[index].artwork = artwork
//                    self.artworkDelegate?.getBookArtworkUrl(artwork, index)
//                }
//            }
//        }
//    }
    
    private func getArtwork(_ html: String) -> String? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let jpgs: Elements = try doc.select("img")
            var images: [String] = []
            for jpg in jpgs {
                images.append(try jpg.attr("data-src"))
            }
            return images.filter { $0.contains("cache") }.first
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return nil
    }
}

// MARK: - Book Site Functions -
extension BookDataViewModel {
    private func getBookLinkForSite(_ site: BookSite, _ html: String) -> String? {
        switch site {
            case .amazon:
                return getAmazonBookLink(html, site)
            case .bkmkitap:
                return getBkmBookLink(html, site)
            case .dnr:
                return getDrBookLink(html, site)
            case .eganba:
                return nil
            case .idefix:
                return nil
            case .istanbul_kitapcisi:
                return nil
            case .kidega:
                return nil
            case .kitapkoala:
                return nil
            case .kitapsepeti:
                return nil
            case .kitapyurdu:
                return getKitapYurduBookLink(html, site)
            case .pandora:
                return nil
            case .ucuz_kitap_al:
                return nil
        }
    }
    
    private func getAmazonBookLink(_ html: String, _ site: BookSite) -> String? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let a: Elements = try doc.select("a")
            let classes = try a.map { try $0.attr("class") }
            let links = try a.map { try $0.attr("href") }
            guard let index = classes.firstIndex(of: "a-link-normal s-faceout-link a-text-normal") else { return nil }
            let link = httpsPrefix + "amazon.com.tr" + links[index]
            return link
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return ""
    }
    
    private func getBkmBookLink(_ html: String, _ site: BookSite) -> String? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let a: Elements = try doc.select("a")
            let classes = try a.map { try $0.attr("class") }
            let links = try a.map { try $0.attr("href") }
            guard let index = classes.firstIndex(of: "fl col-12 text-description detailLink") else { return nil }
            let link = httpsPrefix + "bkmkitap.com" + links[index]
            return link
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return ""
    }
    
    private func getDrBookLink(_ html: String, _ site: BookSite) -> String? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let a: Elements = try doc.select("a")
            let classes = try a.map { try $0.attr("class") }
            let links = try a.map { try $0.attr("href") }
            guard let index = classes.firstIndex(of: "item-name") else { return nil }
            let link = httpsPrefix + "dr.com.tr" + links[index]
            return link
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return ""
    }
    
    private func getKitapYurduBookLink(_ html: String, _ site: BookSite) -> String? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let a: Elements = try doc.select("a")
            let classes = try a.map { try $0.attr("class") }
            let links = try a.map { try $0.attr("href") }
            guard let index = classes.firstIndex(of: "pr-img-link") else { return nil }
            let link = links[index].components(separatedBy: " ").joined(separator: "+")
            return link
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return ""
    }
}

// MARK: - Book Data Functions -
extension BookDataViewModel {
    
    func decideToGetSiteData(_ site: BookSite, _ html: String) -> [String: String]? {
        switch site {
            case .amazon:
                return getAmazonPriceData(html)
            case .bkmkitap:
                return getBkmData(html)
            case .dnr:
                return getDrData(html)
            case .eganba:
                return getEganbaData(html)
            case .idefix:
                return getIdefixData(html)
            case .istanbul_kitapcisi:
                return getIstanbulKitapcisiData(html)
            case .kidega:
                return getKidegaData(html)
            case .kitapkoala:
                return getKitapKoalaData(html)
            case .kitapsepeti:
                return getKitapSepetiData(html)
            case .kitapyurdu:
                return getKitapYurduData(html)
            case .pandora:
                return getPandoraData(html)
            case .ucuz_kitap_al:
                return getUcuzKitapAlData(html)
        }
    }
    
    private func getAmazonPriceData(_ html: String) -> [String: String]? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let spanList: Elements = try doc.select("span")
            let prices = try spanList.map { try $0.text() }.filter { $0.contains("TL") }
            
            guard var price = prices[1].components(separatedBy: "TL").first else { return nil }
            price = price + "₺"
            var discount = prices[2].components(separatedBy: "(").last
            discount?.removeLast()
            
            let priceDic: [String : String] = ["current": price,
                                               "discount": discount ?? ""]
            return priceDic
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return nil
    }
    
    private func getBkmData(_ html: String) -> [String: String]? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let spanList: Elements = try doc.select("span")
            
            let spanClasses = try spanList.map { try $0.attr("class") }
            let spanTexts = try spanList.map { try $0.text() }
            
            guard let currentPriceIndex = spanClasses.firstIndex(of: "product-price"),
                  let discountIndex = spanClasses.firstIndex(of: "col d-flex productDiscount") else { return nil }
            
            let discount = spanTexts[discountIndex].components(separatedBy: " ").first ?? ""
            
            let priceDic: [String : String] = ["current": "\(spanTexts[currentPriceIndex]) ₺",
                                               "discount": discount]
            return priceDic
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return nil
    }
    
    private func getDrData(_ html: String) -> [String: String]? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            
            let divList: Elements = try doc.select("div")
            let divClasses = try divList.map { try $0.attr("class") }
            let divTexts = try divList.map { try $0.text() }
            
            let spanList: Elements = try doc.select("span")
            let spanClasses = try spanList.map { try $0.attr("class") }
            let spanTexts = try spanList.map { try $0.text() }
            
            guard let currentPriceIndex = divClasses.firstIndex(of: "product-price"),
                  let currentPrice = divTexts[currentPriceIndex].components(separatedBy: ")").last?.trimmingCharacters(in: .whitespaces)
                else { return nil }
            
            var discountPercentage: String = ""
            if let discountPriceIndex = spanClasses.firstIndex(of: "discount") {
                discountPercentage = spanTexts[discountPriceIndex].components(separatedBy: "-%").last ?? ""
            }
            
            let priceDic: [String : String] = ["current": currentPrice,
                                               "discount": "%\(discountPercentage)"]
            return priceDic
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return nil
    }
    
    private func getEganbaData(_ html: String) -> [String: String]? {
        return nil
    }
    
    private func getIdefixData(_ html: String) -> [String: String]? {
        return nil
    }
    
    private func getIstanbulKitapcisiData(_ html: String) -> [String: String]? {
        return nil
    }

    private func getKidegaData(_ html: String) -> [String: String]? {
        return nil
    }

    private func getKitapKoalaData(_ html: String) -> [String: String]? {
        return nil
    }

    private func getKitapSepetiData(_ html: String) -> [String: String]? {
        return nil
    }
    
    private func getKitapYurduData(_ html: String) -> [String: String]? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            
            let divList: Elements = try doc.select("div")
            let divClasses = try divList.map { try $0.attr("class") }
            let divTexts = try divList.map { try $0.text() }
            
            let spanList: Elements = try doc.select("span")
            let spanClasses = try spanList.map { try $0.attr("class") }
            let spanTexts = try spanList.map { try $0.text() }
            
            guard let priceIndex = divClasses.firstIndex(of: "price__item") else { return nil }
            let price = "\(divTexts[priceIndex]) ₺"
            
            var discount: String = ""
            if let discountIndex = spanClasses.firstIndex(of: "pr_discount__amount") {
                discount = "%\(spanTexts[discountIndex])"
            }
            
            let priceDic: [String : String] = ["current": price,
                                               "discount": discount]
            return priceDic
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return nil    }
    
    private func getPandoraData(_ html: String) -> [String: String]? {
        return nil
    }

    private func getUcuzKitapAlData(_ html: String) -> [String: String]? {
        return nil
    }
}
