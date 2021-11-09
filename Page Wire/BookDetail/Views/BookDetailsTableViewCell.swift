//
//  BookDetailsTableViewCell.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 11.05.2021.
//

import UIKit
import Nuke

protocol BookDetailsTableViewCellDelegate: AnyObject {
    func selectPublisher()
    func showBookInfo()
}

class BookDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var artwork: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var pagesLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var selectPublisherButton: UIButton!
    @IBOutlet private weak var bookInfoButton: UIButton!
    
    var book: BookModel?
    
    weak var delegate: BookDetailsTableViewCellDelegate?
    
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
    
    private func setArtwork() {
        guard let url = book?.artwork else { return }
        let options = ImageLoadingOptions(
            placeholder: UIImage(systemName: "book.fill"),
            transition: .fadeIn(duration: 0.33)
        )
        Nuke.loadImage(with: URL(string: url)!, options: options, into: artwork)
    }
    
    @IBAction private func selectPublisher(_ sender: Any) {
        delegate?.selectPublisher()
    }
    
    @IBAction private func showBookInfo(_ sender: Any) {
        delegate?.showBookInfo()
    }
}
