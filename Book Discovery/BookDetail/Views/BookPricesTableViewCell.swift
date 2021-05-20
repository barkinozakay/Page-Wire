//
//  BookPricesTableViewCell.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 11.05.2021.
//

import UIKit

protocol NavigateToSite: class {
    func navigateToSite(index: Int)
}

class BookPricesTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var siteNameLabel: UILabel!
    @IBOutlet private weak var discountLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var navigateToSiteButton: UIButton!
    
    var book: BookModel?
    var index: Int = 0
    
    weak var delegate: NavigateToSite?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setBookPricesCell() {
        guard let siteList = book?.sites, !siteList.isEmpty else { return }
        guard let site = siteList[index].site else { return }
        setLogoForSite()
        if site == .dnr {
            siteNameLabel.text = "D&R"
        } else {
            siteNameLabel.text = site.rawValue
        }
        discountLabel.text = book?.discount ?? "%10"
        priceLabel.text = book?.price ?? "100₺"
        navigateToSiteButton.tag = index
    }
    
    private func setLogoForSite() {
        guard let siteList = book?.sites, !siteList.isEmpty else { return }
        guard let site = siteList[index].site else { return }
        var image = UIImage(systemName: "book.fill")
        switch site {
            case .amazon:
                image = UIImage(named: "amazon")
            case .bkmkitap:
                image = UIImage(named: "bkmkitap")
            case .dnr:
                image = UIImage(named: "d&r")
            case .eganba:
                image = UIImage(named: "eganba")
            case .idefix:
                image = UIImage(named: "idefix")
            case .istanbul_kitapcisi:
                image = UIImage(named: "istanbul_kitapçısı")
            case .kidega:
                image = UIImage(named: "kidega")
            case .kitapkoala:
                image = UIImage(named: "kitap_koala")
            case .kitapsepeti:
                image = UIImage(named: "kitap_sepeti")
            case .kitapyurdu:
                image = UIImage(named: "kitap_yurdu")
            case .pandora:
                image = UIImage(named: "pandora")
            case .ucuz_kitap_al:
                image = UIImage(named: "ucuz_kitap_al")
        }
        logoImageView.image = image
    }
    
    @IBAction func navigateToSite(_ sender: UIButton) {
        delegate?.navigateToSite(index: sender.tag)
    }
}
