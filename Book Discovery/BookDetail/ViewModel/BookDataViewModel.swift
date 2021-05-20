//
//  BookDataViewModel.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 20.05.2021.
//

import Foundation
import SwiftSoup

class BookDataViewModel {
    
    private var book: BookModel?
    private var googleSearchQueryPrefix: String = "https://www.google.com.tr/search?q="
    private var httpsPrefix: String = "https://www."
    
    required init(book: BookModel) {
        self.book = book
    }
    
    func getBookDataForSites() -> [BookSiteData]? {
        guard let name = book?.name, let publisher = book?.publisher else { return nil }
        var bookSiteDataList = book?.sites
        bookSiteDataList = []
        for site in BookSite.allCases {
            let query = prepareQuery("\(name) \(publisher) \(site.rawValue) satın al")
            let html = getHtmlFromGoogleSearchQuery(query)
            let link = getLink(html, site)
            if !html.isEmpty, !link.isEmpty {
                bookSiteDataList?.append(BookSiteData(site: site, url: link))
            }
        }
        self.book?.sites = bookSiteDataList
        return bookSiteDataList
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
    
    private func getLink(_ html: String, _ site: BookSite) -> String {
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
    
    func getBookArtworkUrl() -> String? {
        guard let name = book?.name, let publisher = book?.publisher else { return nil }
        let site = BookSite.idefix
        let query = prepareQuery("\(name) \(publisher) \(site.rawValue) satın al")
        let html = getHtmlFromGoogleSearchQuery(query)
        guard !html.isEmpty else { return nil }
        let link = getLink(html, site)
        guard !link.isEmpty else { return nil }
        // PARSE HTML FOR ARTWORK
        let artwork = "ben 1 urlim"
        self.book?.artwork = artwork
        return artwork
    }
}

// MARK: - Book Data Functions -
extension BookDataViewModel {
    
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

