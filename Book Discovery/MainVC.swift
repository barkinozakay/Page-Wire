//
//  MainVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 27.03.2021.
//

import UIKit

class MainVC: UIViewController {

    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var barcodeButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

// MARK: - Search Bar Delegate -
extension MainVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.isAlphaNumeric else { return false }
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        return
    }
}
