//
//  UIViewControllerExtension.swift
//  Dots
//
//  Created by 林晏竹 on 2017/12/16.
//  Copyright © 2017年 林晏竹. All rights reserved.
//

import Foundation

enum ViewTransition {
    case scale, move, none
}

extension UIViewController {
    
    // MARK: - Popup Views
    // popupView frame == view bounds
    func present(_ popupView: UIView, transition: ViewTransition) {
        DispatchQueue.main.async {
            self.view.addSubview(popupView)
            popupView.frame = self.view.bounds
            
            // Prepare for animate in
            switch transition {
            case .scale:
                popupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                popupView.alpha = 0
            case .move:
                popupView.frame.size.height += 64
                popupView.transform = CGAffineTransform(translationX: 0, y: -64)
                popupView.alpha = 0
            case .none:
                popupView.alpha = 0
            }
            
            UIView.animate(withDuration: 0.4) {
                popupView.alpha = 1
                popupView.transform = CGAffineTransform.identity
            }
        }
    }
    
    func dismiss(_ popupView: UIView, transition: ViewTransition) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                switch transition {
                case .scale:
                    popupView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                    popupView.alpha = 0
                case .move:
                    popupView.transform = CGAffineTransform(translationX: 0, y: -64)
                    popupView.alpha = 0
                case .none:
                    popupView.alpha = 0
                }
            }) { (finished) in
                if finished {
                    // Change back to origin
                    popupView.frame.size.height -= 64
                    popupView.transform = CGAffineTransform.identity
                    popupView.alpha = 1
                    
                    popupView.removeFromSuperview()
                }
            }
        }
    }
    
    
    // MARK: - Spinner
    func startAnimating(activityIndicatorView: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            if !activityIndicatorView.isAnimating {
                activityIndicatorView.center = self.view.center
                activityIndicatorView.hidesWhenStopped = true
                activityIndicatorView.activityIndicatorViewStyle = .gray
                self.view.addSubview(activityIndicatorView)
                
                activityIndicatorView.startAnimating()
                self.view.isUserInteractionEnabled = false
            }
        }
    }
    
    func stopAnimating(activityIndicatorView: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            if activityIndicatorView.isAnimating {
                activityIndicatorView.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - Helper Functions
    private func createActIdrBottomView (for activityIndicador: UIActivityIndicatorView) -> UIView {
        let width = activityIndicador.frame.width * 3
        let heigt = width
        let originX = activityIndicador.frame.origin.x - activityIndicador.frame.width
        let originY = activityIndicador.frame.origin.y - activityIndicador.frame.height
        let rect = CGRect(x: originX, y: originY, width: width, height: heigt)
        let bottomView = UIView(frame: rect)
        bottomView.layer.cornerRadius = 3
        bottomView.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        
        return bottomView
    }
}
