//
//  BookDetailsTableViewCell.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 11.05.2021.
//

import UIKit

class BookDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var pagesLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    
    var book: BookModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setBook() {
        titleLabel.text = book?.name
        authorLabel.text = book?.author
        pagesLabel.text = "Pages: \(book?.pages ?? 0)"
        publisherLabel.text = "Publisher: \(book?.publisher ?? "")"
        genresLabel.text = book?.genre
    }
    
}
