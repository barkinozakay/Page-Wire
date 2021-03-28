//
//  BookResultsTableViewCell.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 28.03.2021.
//

import UIKit

class BookResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setBookArtwork(imageURL: String) {
        let imageUrl = URL(string: imageURL)!
        let imageData = try! Data(contentsOf: imageUrl)
        let image = UIImage(data: imageData)
        artwork.image = image
    }
    
    func setBookTitle(text: String) {
        titleLabel.text = text
    }
    
    func setBookAuthor(text: String) {
        authorLabel.text = text
    }
    
}
