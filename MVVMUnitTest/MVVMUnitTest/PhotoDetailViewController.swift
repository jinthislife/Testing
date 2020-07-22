//
//  PhotoDetailViewController.swift
//  MVVMUnitTest
//
//  Created by Jin Lee on 22/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var imageURL: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let url = URL(string: imageURL) {
            imageView.image(from: url)
        }
    }
    
}
