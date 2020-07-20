//
//  ViewController.swift
//  ThirdPartyDependencyTestable
//
//  Created by Jin Lee on 20/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var modelController = ModelController()
    var isTableViewLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelController.fetchFeed { [weak self] errorMessage in
            DispatchQueue.main.async {
                if let message = errorMessage {
                    self?.showAlert(message: message)
                    return
                }
                self?.isTableViewLoaded = true
            }
        }
    }


    private func showAlert(message: String) {
        let ac = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        ac.addAction(action)
        present(ac, animated: true)
    }
}

