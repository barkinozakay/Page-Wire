//
//  BookDataViewModel.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 20.05.2021.
//

import Foundation
import SwiftSoup

protocol BookDataFromSite: AnyObject {
    func getBookDataForSites(_ book: BookModel?, _ isFinished: Bool)
}

protocol BookArtworkFromSite: AnyObject {
    func getBookArtworkUrl(_ artwork: String, _ index: Int)
}

class BookDataViewModel {
    
    var book: BookModel?
    private var books: [BookModel] = []
    
    private var httpsPrefix: String = "https://www."
    
    // TODO: Connect delegate for Main page isbn search.
    weak var siteDataDelegate: BookDataFromSite?
    weak var artworkDelegate: BookArtworkFromSite?
    
    init() {}
    
    init(books: [BookModel]) {
        self.books = books
    }
    
    func getBookDataForSites() {
        var bookSiteDataList = book?.siteData
        bookSiteDataList = []
        var callCounter = 0
        var totalCallCount = BookSite.allCases.count
        for site in BookSite.allCases {
            guard let searchQuery = prepareQuery(site), let siteQueryPrefix = selectQueryForSite(site),
                    !siteQueryPrefix.isEmpty, !searchQuery.isEmpty else {
                totalCallCount -= 1
                continue
            }
            // TODO: Test for wrong site urls.
            getHtmlFromSearchQuery(siteQueryPrefix + searchQuery) { (response) in
                guard let html = response, !html.isEmpty else { return }
                guard let bookLink = self.getBookLinkForSite(site, html), !bookLink.isEmpty else { return totalCallCount -= 1 }
                self.startNewSessionAsync(URL(string: bookLink)) { (response) in
                    callCounter += 1
                    guard let responseHtml = response else { return }
                    let isFinished = callCounter == totalCallCount ? true : false
                    self.parseBookArtwork(site, responseHtml)
                    self.parseBookInfo(site, responseHtml)
                    self.addBookSiteData(site, responseHtml, bookLink, &bookSiteDataList)
                    self.sortPrices(&bookSiteDataList)
                    self.book?.siteData = bookSiteDataList
                    self.siteDataDelegate?.getBookDataForSites(self.book, isFinished)
                }
            }
        }
    }
    
    private func prepareQuery(_ site: BookSite) -> String? {
        switch site {
        case .amazon, .dnr, .idefix:
            guard let isbn = book?.isbn?.description else { return nil }
            return isbn
        case .kitapyurdu:   // TODO: search query with ISBN?
            guard let name = book?.name, let author = book?.author?.components(separatedBy: " ").last else { return nil }
            return formatQuery(query: "\(name) \(author)")
        default:
            return nil
        }
    }
    
    private func formatQuery(query: String) -> String? {
        var newQuery = query
        newQuery.getAlphaNumericValue()
        newQuery = newQuery.removeDiacritics().split(separator: " ").joined(separator: "+")
        return newQuery
    }
    
    private func selectQueryForSite(_ site: BookSite) -> String? {
        switch site {
        case .amazon:
            return httpsPrefix + "amazon.com.tr/s?k="
        case .dnr:
            return httpsPrefix + "dr.com.tr/search?q="
        case .idefix:
            return httpsPrefix + "idefix.com/search/?Q="
        case .kitapyurdu:
            return httpsPrefix + "kitapyurdu.com/index.php?route=product/search&filter_name="
        case .pandora:
            return httpsPrefix + "pandora.com.tr/Arama/?type=9&isbn="
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
    
    private func parseBookArtwork(_ site: BookSite, _ html: String) {
        guard site == .idefix else { return }
        let artwork: String? = self.getArtwork(html)
        self.book?.artwork = artwork
    }
    
    private func parseBookInfo(_ site: BookSite, _ html: String) {
        guard site == .amazon else { return }
        let info = self.getBookInfo(html)
        self.book?.info = info
    }
    
    private func getBookInfo(_ html: String) -> String {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let a: Elements = try doc.select("div")
            let classes = try a.map { try $0.attr("class") }
            let texts = try a.map { try $0.text() }
            guard let index = classes.firstIndex(of: "a-section a-spacing-large text-direction-override") else { return "" }
            let info = texts[index]
            return info
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return ""
    }
    
    func getBookArtworkUrl() {
        var artwork: String = ""
        for index in 0..<books.count {
            guard index < 9 else { break }
            guard let searchQuery = books[index].isbn?.description else { continue }
            guard let siteQueryPrefix = selectQueryForSite(.idefix) else { continue }
            getHtmlFromSearchQuery(siteQueryPrefix + searchQuery) { (response) in
                guard let html = response, !html.isEmpty else { return }
                guard let bookLink = self.getBookLinkForSite(.idefix, html), !bookLink.isEmpty else { return }
                self.startNewSessionAsync(URL(string: bookLink)) { (response) in
                    guard let responseHtml = response else { return }
                    artwork = self.getArtwork(responseHtml) ?? ""
                    self.books[index].artwork = artwork
                    self.artworkDelegate?.getBookArtworkUrl(artwork, index)
                }
            }
        }
    }
    
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
    
    private func sortPrices(_ bookSiteDataList: inout [BookSiteData]?) {
        guard let list = bookSiteDataList else { return }
        bookSiteDataList = list.sorted(by: { $0.price ?? 0.0 < $1.price ?? 0.0 })
    }
    
    private func addBookSiteData(_ site: BookSite, _ html: String, _ bookLink: String, _ bookSiteDataList: inout [BookSiteData]?) {
        if let dic = self.decideToGetSiteData(site, html) {
            if let price = dic["price"] as? Double, let discount = dic["discount"] as? String {
                bookSiteDataList?.append(BookSiteData(site: site, url: bookLink, price: price, discount: discount))
            }
        }
    }
}

// MARK: - Book Site Functions
extension BookDataViewModel {
    private func getBookLinkForSite(_ site: BookSite, _ html: String) -> String? {
        switch site {
        case .amazon:
            return getAmazonBookLink(html)
        case .dnr:
            return getDrBookLink(html)
        case .eganba:
            return nil
        case .idefix:
            return getIdefixBookLink(html)
        case .istanbul_kitapcisi:
            return nil
        case .kidega:
            return nil
        case .kitapkoala:
            return nil
        case .kitapsepeti:
            return nil
        case .kitapyurdu:
            return getKitapYurduBookLink(html)
        case .pandora:
            return nil
        case .ucuz_kitap_al:
            return nil
        }
    }
    
    private func getAmazonBookLink(_ html: String) -> String? {
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
    
//    private func getBkmBookLink(_ html: String) -> String? {
//        do {
//            let doc: Document = try SwiftSoup.parse(html)
//            let a: Elements = try doc.select("a")
//            let classes = try a.map { try $0.attr("class") }
//            let links = try a.map { try $0.attr("href") }
//            guard let index = classes.firstIndex(of: "fl col-12 text-description detailLink") else { return nil }
//            let link = httpsPrefix + "bkmkitap.com" + links[index]
//            return link
//        } catch Exception.Error(let type, let message) {
//            print("Error Type: \(type)")
//            print("Error Message: \(message)")
//        } catch {
//            print("Error")
//        }
//        return ""
//    }
    
    private func getDrBookLink(_ html: String) -> String? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let a: Elements = try doc.select("a")
            let links = try a.map { try $0.attr("href") }
            let texts = try a.map { try $0.text() }
            guard let bookName = book?.name, !bookName.isEmpty else { return nil }
            guard let index = texts.firstIndex(where: { $0.contains(bookName) }) else { return nil }
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
    
    private func getIdefixBookLink(_ html: String) -> String? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let a: Elements = try doc.select("a")
            let classes = try a.map { try $0.attr("class") }
            let links = try a.map { try $0.attr("href") }
            guard let index = classes.firstIndex(of: "product-image") else { return nil }
            let link = links[index].components(separatedBy: " ").joined(separator: "+")
            return httpsPrefix + "idefix.com" + link
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return ""
    }
    
    private func getKitapYurduBookLink(_ html: String) -> String? {
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
    
    private func getPandoraBookLink(_ html: String) -> String? {
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

// MARK: - Book Data Functions
extension BookDataViewModel {
    
    func decideToGetSiteData(_ site: BookSite, _ html: String) -> [String: Any]? {
        switch site {
        case .amazon:
            return getAmazonPriceData(html)
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
    
    private func getAmazonPriceData(_ html: String) -> [String: Any]? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let spanList: Elements = try doc.select("span")
            
            let spanClasses = try spanList.map { try $0.attr("class") }
            let spanTexts = try spanList.map { try $0.text() }
            
            guard let currentPriceIndex = spanClasses.firstIndex(of: "a-size-base a-color-price") else { return nil }
            
            guard let price = spanTexts[currentPriceIndex].components(separatedBy: "TL").first?.toDouble()?.rounded(toPlaces: 2) else { return nil }
            var discount = spanTexts.filter { $0.contains("TL") && $0.contains("%") }.first?.components(separatedBy: "(").last

            discount?.trimmingAllSpaces()
            discount?.removeLast()
            
            let priceDic: [String : Any] = ["price": price,
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
    
//    private func getBkmData(_ html: String) -> [String: Any]? {
//        do {
//            let doc: Document = try SwiftSoup.parse(html)
//            let spanList: Elements = try doc.select("span")
//
//            let spanClasses = try spanList.map { try $0.attr("class") }
//            let spanTexts = try spanList.map { try $0.text() }
//
//            guard let currentPriceIndex = spanClasses.firstIndex(of: "product-price"),
//                  let discountIndex = spanClasses.firstIndex(of: "col d-flex productDiscount") else { return nil }
//
//            guard let price = spanTexts[currentPriceIndex].toDouble()?.rounded(toPlaces: 2) else { return nil }
//            let discount = spanTexts[discountIndex].components(separatedBy: " ").first ?? ""
//
//            let priceDic: [String : Any] = ["price": price,
//                                            "discount": discount]
//            return priceDic
//        } catch Exception.Error(let type, let message) {
//            print("Error Type: \(type)")
//            print("Error Message: \(message)")
//        } catch {
//            print("Error")
//        }
//        return nil
//    }
    
    private func getDrData(_ html: String) -> [String: Any]? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            
            let divList: Elements = try doc.select("div")
            let divClasses = try divList.map { try $0.attr("class") }
            let divTexts = try divList.map { try $0.text() }
            
            let spanList: Elements = try doc.select("span")
            let spanClasses = try spanList.map { try $0.attr("class") }
            let spanTexts = try spanList.map { try $0.text() }
            
            guard let priceIndex = divClasses.firstIndex(of: "salePrice"),
                  let price = divTexts[priceIndex].components(separatedBy: " ").first?.toDouble()?.rounded(toPlaces: 2)  else { return nil }
            
            var discount: String = ""
            if let discountIndex = spanClasses.firstIndex(of: "discount-rate") {
                discount = spanTexts[discountIndex]
            }
            
            let priceDic: [String : Any] = ["price": price,
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
    
    private func getEganbaData(_ html: String) -> [String: Any]? {
        return nil
    }
    
    private func getIdefixData(_ html: String) -> [String: Any]? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            
            let divList: Elements = try doc.select("div")
            let divClasses = try divList.map { try $0.attr("class") }
            let divTexts = try divList.map { try $0.text() }
            
            let spanList: Elements = try doc.select("span")
            let spanClasses = try spanList.map { try $0.attr("class") }
            let spanTexts = try spanList.map { try $0.text() }
            
            guard let priceIndex = divClasses.firstIndex(of: "current-price"),
                  let price = divTexts[priceIndex].components(separatedBy: " ").first?.toDouble()?.rounded(toPlaces: 2)  else { return nil }
            
            var discount: String = ""
            if let discountIndex = spanClasses.firstIndex(of: "discount") {
                discount = spanTexts[discountIndex]
            }
            
            let priceDic: [String : Any] = ["price": price,
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
    
    private func getIstanbulKitapcisiData(_ html: String) -> [String: Any]? {
        return nil
    }

    private func getKidegaData(_ html: String) -> [String: Any]? {
        return nil
    }

    private func getKitapKoalaData(_ html: String) -> [String: Any]? {
        return nil
    }

    private func getKitapSepetiData(_ html: String) -> [String: Any]? {
        return nil
    }
    
    private func getKitapYurduData(_ html: String) -> [String: Any]? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            
            let divList: Elements = try doc.select("div")
            let divClasses = try divList.map { try $0.attr("class") }
            let divTexts = try divList.map { try $0.text() }
            
            let spanList: Elements = try doc.select("span")
            let spanClasses = try spanList.map { try $0.attr("class") }
            let spanTexts = try spanList.map { try $0.text() }
            
            guard let priceIndex = divClasses.firstIndex(of: "price__item"),
                  let price = divTexts[priceIndex].toDouble()?.rounded(toPlaces: 2) else { return nil }
            
            var discount: String = ""
            if let discountIndex = spanClasses.firstIndex(of: "pr_discount__amount") {
                discount = "%\(spanTexts[discountIndex])"
            }
            
            let priceDic: [String : Any] = ["price": price,
                                            "discount": discount]
            return priceDic
        } catch Exception.Error(let type, let message) {
            print("Error Type: \(type)")
            print("Error Message: \(message)")
        } catch {
            print("Error")
        }
        return nil    }
    
    private func getPandoraData(_ html: String) -> [String: Any]? {
        return nil
    }

    private func getUcuzKitapAlData(_ html: String) -> [String: Any]? {
        return nil
    }
}
