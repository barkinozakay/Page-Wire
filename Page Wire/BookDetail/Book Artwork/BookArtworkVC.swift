//
//  BookArtworkVC.swift
//  Page Wire
//
//  Created by Barkın Özakay on 15.12.2021.
//

import UIKit
import Hero

class BookArtworkVC: UIViewController {

    @IBOutlet private weak var backView: UIView!
    @IBOutlet private weak var artwork: UIImageView!
    
    var artworkImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = ""
        setArtworkImage()
    }
    
    private func setArtworkImage() {
        artwork.heroID = "artwork"
        artwork.image = artworkImage
    }
    
    @IBAction private func onArtworkPanned(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        let progress = translation.y / 2 / screenHeight
        switch sender.state {
        case .began:
            hero.dismissViewController()
        case .changed:
            Hero.shared.update(progress)
            let currentPosition = CGPoint(x: translation.x + artwork.center.x, y: translation.y + artwork.center.y)
            Hero.shared.apply(modifiers: [.position(currentPosition)], to: artwork)
        default:
            progress > 0.1 ? Hero.shared.finish() : Hero.shared.cancel()
        }
    }
}
