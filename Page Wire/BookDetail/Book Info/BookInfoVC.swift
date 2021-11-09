//
//  BookInfoVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 24.05.2021.
//

import UIKit

class BookInfoVC: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var textView: UITextView!
    
    var book: BookModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    private func setUI() {
        let name = book?.name ?? ""
        let author = book?.author ?? ""
        titleLabel.text = name
        authorLabel.text = author
        setInfoText()
    }

    private func setInfoText() {
        let attributedString = NSMutableAttributedString(string: book?.info ?? "", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular)])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        textView.attributedText = attributedString
    }
}
