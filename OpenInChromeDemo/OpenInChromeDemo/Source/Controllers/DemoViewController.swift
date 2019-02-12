//
//  DemoViewController.swift
//  OpenInChromeDemo
//
//  Created by Luigi Aiello on 12/02/2019.
//  Copyright © 2019 Luigi Aiello. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var openLinkButton: UIButton!
    
    // MARK: - Variables
    private let link = "https://about.me/luigiaiello"
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    @IBAction func openLinkDidTap(_ sender: Any) {
        if OpenInChromeController.shared.isChromeInstalled() {
            do {
                if #available(iOS 10.0, *) {
                    try OpenInChromeController.shared.openInChrome(URL(string: link)!, callbackURL: nil, createNewTab: false, completionHandler: nil)
                } else {
                    try OpenInChromeController.shared.openInChrome(URL(string: link)!, callbackURL: nil, createNewTab: false)
                }
            } catch let error {
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                self.showAlert(title: "Error", message: "Cannot open link: \(error.localizedDescription)", actions: [okAction])
            }
        } else {
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            self.showAlert(title: "Error", message: "Chrome browser is not installed. Go to Apple Store and download it", actions: [okAction])
        }
    }
}
