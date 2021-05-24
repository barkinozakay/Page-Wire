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
    private var googleSearchQueryPrefix: String = "https://www.google.com.tr/search?q="
    private var httpsPrefix: String = "https://www."
    
    weak var siteDataDelegate: BookDataFromSiteDelegate?
    weak var artworkDelegate: BookArtworkFromSiteDelegate?
    
    init(book: BookModel) {
        self.book = book
    }
    
    init(books: [BookModel]) {
        self.books = books
    }
    
    func getBookDataForSites() {
        guard let name = book?.name, let publisher = book?.publisher else { return }
        var bookSiteDataList = book?.siteData
        bookSiteDataList = []
        var counter = 0
        for site in BookSite.allCases {
            let query = prepareQuery("\(name) \(publisher) \(site.rawValue) satın al")
            getHtmlFromGoogleSearchQuery(query) { (response) in
                counter += 1
                guard let html = response, !html.isEmpty else { return }
                guard let link = self.getLink(html, site), !link.isEmpty else { return }
                let isFinished = counter == BookSite.allCases.count ? true : false
                self.startNewSessionAsync(URL(string: link)) { (response) in
                    guard let responseHtml = response else { return }
                    if site == .idefix {
                        let artwork: String? = self.getArtwork(responseHtml)
                        self.book?.artwork = artwork
                    }
                    let price: [String: String]? = self.decideToGetSiteData(site, responseHtml)
                    bookSiteDataList?.append(BookSiteData(site: site, url: link, price: price))
                    self.siteDataDelegate?.getBookDataForSites(bookSiteDataList, isFinished)
                }
            }
        }
        self.book?.siteData = bookSiteDataList
    }
    
    private func getHtmlFromGoogleSearchQuery(_ query: String, _ comp: @escaping (String?) -> ()) {
        guard !query.isEmpty else { return }
        var html: String?
        let url = URL(string: googleSearchQueryPrefix + query)
        startNewSessionAsync(url, delay: 1.0) { (content) in    // Minimum delay time for Google Search Query --> 0.6 sec
            html = content
            comp(html)
        }
    }
    
    private func startNewSessionAsync(_ url: URL?, delay: Double = 0.0, _ comp: @escaping (String?) -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if error != nil {
                    print(error!)
                } else {
                    comp(String(decoding: data!, as: UTF8.self))
                }
            }.resume()
        }
    }
    
    private func startNewSessionSync(_ url: URL?, _ comp: @escaping (String?) -> ()) { // MARK: - MAIN THREAD LOADING ANIMASYONUNU ENGELLIYOR ! -
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                comp(String(decoding: data!, as: UTF8.self))
            }
            semaphore.signal()
        }.resume()
        sleep(UInt32(0.6)) // Minimum delay time for Google Search Query
        semaphore.wait()
    }
    
    private func prepareQuery(_ query: String) -> String {
        var newQuery = query
        newQuery.getAlphaNumericValue()
        newQuery = newQuery.removeDiacritics().split(separator: " ").joined(separator: "+")
        return newQuery
    }
    
    private func getLink(_ html: String, _ site: BookSite) -> String? {
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let linkElements: Elements = try doc.select("a")
            var links: [String] = []
            for link in linkElements {
                links.append(try link.attr("href"))
            }
            let urlPrefix = site.rawValue.removeDiacritics().lowercased().replacingOccurrences(of: " ", with: "")
            return links.filter { $0.hasPrefix(httpsPrefix + urlPrefix) }.first
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
            let name = books[index].name
            let publisher = books[index].publisher
            let site = BookSite.idefix
            let query = prepareQuery("\(name) \(publisher) \(site.rawValue) satın al")
            getHtmlFromGoogleSearchQuery(query) { (response) in
                guard let html = response, !html.isEmpty else { return }
                guard let link = self.getLink(html, site), !link.isEmpty else { return }
                let url = URL(string: link)
                self.startNewSessionAsync(url, delay: 0.1) { (content) in
                    guard let siteHtml = content, !siteHtml.isEmpty else { return }
                    artwork = self.getArtwork(siteHtml) ?? ""
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
            let priceList: Elements = try doc.select("span")
            let prices = try priceList.map { try $0.text() }.filter { $0.contains("TL") }
            let priceDic: [String : String] = ["current": prices[1],
                                               "discount": prices[2]]
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
            let priceList: Elements = try doc.select("span")
            let spanClasses = try priceList.map { try $0.attr("class") }
            let prices = try priceList.map { try $0.text() }
            
            guard let originalPriceIndex = spanClasses.firstIndex(of: "product-price-not-discounted"),
                  let currentPriceIndex = spanClasses.firstIndex(of: "product-price"),
                  let discountPriceIndex = spanClasses.firstIndex(of: "col d-flex productDiscount") else { return nil }
            
            guard let discount = calculateDiscountAmountBKM(prices[originalPriceIndex], prices[discountPriceIndex]) else { return nil }
            
            let priceDic: [String : String] = ["current": "\(prices[currentPriceIndex]) TL",
                                               "discount": "\(discount)"]
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
                discountPercentage = spanTexts[discountPriceIndex].components(separatedBy: "-%").last ?? "0"
            }
            
            let priceDic: [String : String] = ["current": currentPrice,
                                               "discount": "% \(discountPercentage)"]
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
        return nil
    }
    
    private func getPandoraData(_ html: String) -> [String: String]? {
        return nil
    }

    private func getUcuzKitapAlData(_ html: String) -> [String: String]? {
        return nil
    }
}

// MARK: - Book Data From Site Helper Functions -
extension BookDataViewModel {
    private func calculateDiscountAmountBKM(_ originalPrice: String, _ discountPercentage: String) -> String? {
        guard let original = Double(originalPrice.components(separatedBy: ",").first!),
              let discount = Double(discountPercentage.components(separatedBy: " ").first!.components(separatedBy: "%").last!) else { return nil }
        let discountPrice = original * discount / 100.0
        return "\(discountPrice.rounded(toPlaces: 2)) TL (% \(Int(discount)))"
    }
}

