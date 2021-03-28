//
//  MainVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 27.03.2021.
//

import UIKit
import Lottie

class MainVC: UIViewController {

    // MARK: - Variables -
    @IBOutlet private weak var segmentedControl: UISegmentedControl!
    @IBOutlet private weak var searchBar: UISearchBar!
    @IBOutlet private weak var searchButton: UIButton!
    @IBOutlet private weak var cameraButton: UIButton!
    @IBOutlet private weak var barcodeButton: UIButton!
    
    private lazy var searchBarText: String = ""
    private lazy var animationView = AnimationView(name: "searching_books_animation")
    private lazy var blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.8
        blurEffectView.isHidden = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return blurEffectView
    }()
    private lazy var showLoadingAnimation: Bool = false {
        didSet {
            if showLoadingAnimation {
                animationView.isHidden = false
                blurEffectView.isHidden = false
                view.isUserInteractionEnabled = false
                animationView.play()
            } else {
                animationView.isHidden = true
                blurEffectView.isHidden = true
                view.isUserInteractionEnabled = true
                animationView.stop()
            }
        }
    }
}

// MARK: - LIFECYCLE -
extension MainVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLottieAnimation()
    }
}

// MARK: - IBActions -
extension MainVC {
    
    @IBAction func searchButtonAction(_ sender: Any) {
        // Check from csv before the navigation.
        goToBookResults()
    }
}

// MARK: - Navigation Functions -
extension MainVC {
    
    private func goToBookResults() {
        guard !searchBarText.isEmpty else {
            showAlert(title: "", message: "Search Text can not be empty!", okTitle: "OK", cancelTitle: nil, okAction: nil, cancelAction: nil)
            return
        }
        showLoadingAnimation = true
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BookResultsVC") as! BookResultsVC
        vc.searchText = searchBarText
        //navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Loading Animation -
extension MainVC {
    
    private func setLottieAnimation() {
        let size = view.frame.width + 100
        animationView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        animationView.center = view.center
        animationView.backgroundColor = .clear
        animationView.loopMode = .loop
        animationView.contentMode = .scaleAspectFill
        animationView.isHidden = true
        view.addSubview(animationView)
        view.insertSubview(blurEffectView, at: 0)
    }
}

// MARK: - Search Bar Delegate -
extension MainVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.isAlphaNumeric else { return false }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let text = searchBar.text else { return }
        searchBarText = text
    }
}
