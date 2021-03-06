//
//  BookDetailsTableViewCell.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 11.05.2021.
//

import UIKit
import Nuke
import Hero

protocol BookDetailsTableViewCellDelegate: AnyObject {
    func selectPublisher()
    func showBookInfo()
    func onArtworkTapped(_ image: UIImage?)
}

class BookDetailsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var artworkContainerView: UIView!
    @IBOutlet private weak var artwork: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var pagesLabel: UILabel!
    @IBOutlet private weak var publisherLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var selectPublisherButton: UIButton!
    @IBOutlet private weak var bookInfoButton: UIButton!
    
    var book: BookModel?
    
    weak var delegate: BookDetailsTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGestureForArtwork()
        artwork.applyShadowWithCorner(containerView: artworkContainerView, cornerRadius: 5)
    }
    
    func setBook() {
        setArtwork()
        titleLabel.text = book?.name
        authorLabel.text = book?.author
        publisherLabel.text = book?.publisher
        genresLabel.text = book?.genre
        pagesLabel.text = "Pages: \(book?.pages ?? 0)"
        checkForScannedBook()
    }
    
    private func setArtwork() {
        guard let urlStr = book?.artwork, !urlStr.isEmpty, let artworkUrl = URL(string: urlStr) else { return }
        let options = ImageLoadingOptions(
            placeholder: UIImage(systemName: "book.fill"),
            transition: .fadeIn(duration: 0.05)
        )
        Nuke.loadImage(with: artworkUrl, options: options, into: artwork) { _ in
            self.artwork.contentMode = .scaleToFill
        }
    }
    
    private func checkForScannedBook() {
        let isScanned = book?.isScanned ?? false
        publisherLabel.isHidden = isScanned
        selectPublisherButton.isHidden = isScanned
    }
    
    private func addTapGestureForArtwork() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onArtworkTapped))
        artwork.isUserInteractionEnabled = true
        artwork.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func onArtworkTapped() {
        let artworkImage = artwork.image ?? UIImage(systemName: "book.fill")
        artwork.heroID = "artwork"
        delegate?.onArtworkTapped(artworkImage)
    }
    
    @IBAction private func selectPublisher(_ sender: Any) {
        delegate?.selectPublisher()
    }
    
    @IBAction private func showBookInfo(_ sender: Any) {
        delegate?.showBookInfo()
    }
}
