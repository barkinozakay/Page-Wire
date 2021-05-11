//
//  BookPricesTableViewCell.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 11.05.2021.
//

import UIKit

class BookPricesTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var siteNameLabel: UILabel!
    @IBOutlet private weak var discountLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var navigateToSiteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setBookPricesCell() {
        siteNameLabel.text = "Amazon"
        discountLabel.text = "%30"
        priceLabel.text = "30₺"
    }
}
