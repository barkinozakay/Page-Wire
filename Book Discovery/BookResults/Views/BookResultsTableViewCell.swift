//
//  BookResultsTableViewCell.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 28.03.2021.
//

import UIKit
import Nuke

class BookResultsTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var artwork: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var pagesLabel: UILabel!
    @IBOutlet private weak var publisherLabel: UILabel!
    @IBOutlet private weak var favoriteButton: UIButton!
    
    var book: BookModel?
    var hideFavoriteButton: Bool = false {
        didSet {
            favoriteButton.isHidden = hideFavoriteButton
        }
    }
    
    weak var favoriteDelegate: FavoriteBook?

    override func awakeFromNib() {
        super.awakeFromNib()
        favoriteButton.addTarget(self, action: #selector(changeFavorite), for: .touchUpInside)
    }
    
    
    func setBook() {
        setArtwork()
        titleLabel.text = book?.name
        authorLabel.text = book?.author
        pagesLabel.text = "Pages: \(book?.pages ?? 0)"
        publisherLabel.text = "Publisher: \(book?.publisher ?? "")"
    }
    
    private func setArtwork() {
        guard let url = book?.artwork else { return }
        let options = ImageLoadingOptions(
            placeholder: UIImage(systemName: "book.fill"),
            transition: .fadeIn(duration: 0.33)
        )
        Nuke.loadImage(with: URL(string: url)!, options: options, into: artwork)
    }
    
    @objc func changeFavorite() {
        changeFavoriteButtonState()
        favoriteDelegate?.changeFavoriteState(book)
    }
    
    private func changeFavoriteButtonState() {
        let isFavorited = book?.isFavorited ?? false
        book?.isFavorited = !isFavorited
        setFavoriteButtonImage()
    }
    
    func setFavoriteButtonImage() {
        if let isFavorited = book?.isFavorited, isFavorited {
            favoriteButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favoriteButton.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
}
