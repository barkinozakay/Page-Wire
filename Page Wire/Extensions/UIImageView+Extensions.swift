//
//  UIImageView+Extensions.swift
//  Page Wire
//
//  Created by Barkın Özakay on 13.12.2021.
//

import UIKit
import Foundation

extension UIImageView {
    func applyShadowWithCorner(containerView : UIView, cornerRadius : CGFloat){
        containerView.clipsToBounds = false
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowOffset = CGSize.zero
        containerView.layer.shadowRadius = 2
        containerView.layer.cornerRadius = cornerRadius
        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: cornerRadius).cgPath
        self.clipsToBounds = true
        self.layer.cornerRadius = cornerRadius
    }
}
