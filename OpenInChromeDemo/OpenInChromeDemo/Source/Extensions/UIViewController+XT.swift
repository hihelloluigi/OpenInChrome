//
//  UIViewController+Utility.swift
//  FirmaDigitale
//
//  Created by Giorgio Fiderio on 17/03/17.
//  Copyright © 2017 Aruba S.p.A. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?, actions: [UIAlertAction], completionHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for action in actions {
            alertController.addAction(action)
        }
        
        present(alertController, animated: true, completion: completionHandler)
    }
}
