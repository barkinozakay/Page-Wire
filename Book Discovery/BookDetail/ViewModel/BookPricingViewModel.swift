//
//  BookPricingViewModel.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 19.05.2021.
//

import Foundation
import SwiftSoup

class BookPricingViewModel {
    
    private var book: BookModel?
    private var googleSearchQueryPrefix: String = "https://www.google.com.tr/search?q="
    private var httpsPrefix: String = "https://www."
    
    private var bookDataList: [BookDataModel?] = []
    
    required init(book: BookModel) {
        self.book = book
    }
    
    func getBookDataForSites() -> [BookDataModel?] {
        guard let name = book?.name, let publisher = book?.publisher else { return [] }
        for site in BookPricingSite.allCases {
            let query = prepareQuery("\(name) \(publisher) \(site.rawValue) satın al")
            let html = getHtmlFromGoogleSearchQuery(query)
            let link = getLink(html, site)
            if !html.isEmpty, !link.isEmpty {
                let bookData = BookDataModel(site: site, price: nil, discount: nil, url: link)
                bookDataList.append(bookData)
            }
        }
        return bookDataList
    }
    
    private func getHtmlFromGoogleSearchQuery(_ query: String) -> String {
        guard !query.isEmpty else { return "" }
        var html: String?
        let url = URL(string: googleSearchQueryPrefix + query)
        startNewSessionSync(url) { (content) in
            html = content
        }
        return html ?? ""
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
    
    private func getLink(_ html: String, _ site: BookPricingSite) -> String {
        guard !html.isEmpty else { return "" }
        do {
            let doc: Document = try SwiftSoup.parse(html)
            let linkElements: Elements = try doc.select("a")
            var links: [String] = []
            for link in linkElements {
                links.append(try link.attr("href"))
            }
            let urlPrefix = site.rawValue.removeDiacritics().lowercased().replacingOccurrences(of: " ", with: "")
            return links.filter { $0.hasPrefix(httpsPrefix + urlPrefix) }.first ?? ""
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
extension BookPricingViewModel {
    
    func decideToGetSiteData() {
        getAmazonData()
    }
    
    private func getAmazonData() {
        
    }
    
//    private func getBkmData() {
//
//    }
    
    private func getDrData() {
        
    }
    
//    private func getEganbaData() {
//
//    }
    
    private func getIdefixData() {
        
    }
    
//    private func getIstanbulKitapcisiData() {
//
//    }
//
//    private func getKidegaData() {
//
//    }
//
//    private func getKitapKoalaData() {
//
//    }
//
//    private func getKitapSepetiData() {

//    }
    
    private func getKitapYurduData() {
        
    }
    
//    private func getPandoraData() {
//
//    }
//
//    private func getUcuzKitapAlData() {
//
//    }
}
