//
//  DecodeHelper.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 31.03.2021.
//

import UIKit

class DecoderHelper: NSObject {
    
    private override init() { }
    
    static func decode<T>(resourcePath: String, _ type: T.Type) -> T? where T: Codable {
        if let path = Bundle.main.path(forResource: resourcePath, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONDecoder().decode(T.self, from: data)
                return jsonResult
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
}
