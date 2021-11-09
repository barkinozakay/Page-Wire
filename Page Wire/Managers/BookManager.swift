//
//  BookManager.swift
//  Page Wire
//
//  Created by Barkın Özakay on 10.11.2021.
//

import Foundation

class BookManager: NSObject {
    
    private override init() { }
    
    static var shared = BookManager()
    
    var bookList: [BookModel] = []
}
