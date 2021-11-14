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
    
    var book: BookModel?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setBook() {
        setArtwork()
        titleLabel.text = book?.name
        authorLabel.text = book?.author
    }
    
    private func setArtwork() {
        guard let url = book?.artwork, !url.isEmpty else { return }
        let options = ImageLoadingOptions(
            transition: .fadeIn(duration: 0.33)
        )
        Nuke.loadImage(with: URL(string: url)!, options: options, into: artwork) { _ in
            self.artwork.clipsToBounds = true
            self.artwork.contentMode = .scaleAspectFit
        }
    }
}
