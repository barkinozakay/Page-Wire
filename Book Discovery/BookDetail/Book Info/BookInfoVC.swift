//
//  BookInfoVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 24.05.2021.
//

import UIKit

class BookInfoVC: UIViewController {

    @IBOutlet private weak var textView: UITextView!
    
    var bookInfo: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = bookInfo
    }

}
