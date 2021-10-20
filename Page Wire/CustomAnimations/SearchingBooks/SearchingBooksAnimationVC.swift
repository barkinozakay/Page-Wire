//
//  SearchingBooksAnimationVC.swift
//  Book Discovery
//
//  Created by Barkın Özakay on 28.03.2021.
//

import UIKit
import Lottie

class SearchingBooksAnimationVC: UIViewController {

    internal final var previousController: UIViewController?
    
//    var blurEffectView: UIVisualEffectView = {
//        let blurEffect = UIBlurEffect(style: .dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.alpha = 0.8
//        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        return blurEffectView
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        //blurEffectView.frame = self.view.bounds
        //view.insertSubview(blurEffectView, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        asyncOperation {
            self.setLottieAnimation()
        }
    }
    
    func setLottieAnimation() {
        view.backgroundColor = UIColor.white
        let animationView = AnimationView(name: "searching_books_animation")
        let size = view.frame.width - 150
        animationView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        animationView.center = self.view.center
        animationView.contentMode = .scaleAspectFill
        view.addSubview(animationView)
        animationView.play(fromProgress: 0, toProgress: 1, loopMode: .loop)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

}
