//
//  BookDetailsTableViewCell.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 11.05.2021.
//

import UIKit
import Nuke

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
        setArtwork()
        titleLabel.text = book?.name
        authorLabel.text = book?.author
        publisherLabel.text = book?.publisher
        genresLabel.text = book?.genre
        pagesLabel.text = "Pages: \(book?.pages ?? 0)"
    }
    
    func setArtwork() {
        guard let url = book?.artwork else { return }
        let options = ImageLoadingOptions(
            placeholder: UIImage(systemName: "book.fill"),
            transition: .fadeIn(duration: 0.33)
        )
        Nuke.loadImage(with: URL(string: url)!, options: options, into: artwork)
    }
    
}
