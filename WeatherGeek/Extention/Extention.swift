//
//  Extention.swift
//  WeatherGeek
//
//  Created by Lê Duy on 5/26/20.
//  Copyright © 2020 Lê Duy. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}

extension UIView {
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.default)
        animation.type = CATransitionType.moveIn
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
}

class Alert {
    var timer: Timer?
    
    public static func showAlert(on vc:UIViewController, withTitle: String, message:String){
        let alert = UIAlertController(title: withTitle, message: message, preferredStyle: .alert)
        DispatchQueue.main.async {
            vc.present(alert, animated: true)
            alert.dismiss(animated: true, completion: nil)
        }
        
    }
}

