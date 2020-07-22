//
//  PhotoListViewController.swift
//  MVVMUnitTest
//
//  Created by Jin Lee on 21/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import UIKit

class PhotoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var viewModel: PhotoListViewModel = {
        return PhotoListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        
        initVM()
    }
    
    func initView() {
        self.navigationItem.title = "Popular"
        
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    func initVM() {

        viewModel.showAlertClosure = { [weak self] in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert(message)
                }
            }
            
        }
        
        viewModel.updateLoadingStatus = { [weak self] in
            DispatchQueue.main.async {

            let isLoading = self?.viewModel.isLoading ?? false
            
            if isLoading {
                self?.activityIndicator.startAnimating()
                UIView.animate(withDuration: 0.2, animations: {
                    self?.tableView.alpha = 0.0
                })
            } else {
                self?.activityIndicator.stopAnimating()
                UIView.animate(withDuration: 0.2, animations: {
                    self?.tableView.alpha = 1.0
                })
            }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.initFetch()
    }
    
    func showAlert(_ message: String) {
        let ac = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(ac, animated: true)
    }

}


extension PhotoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCells
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: "photoCellIdentifier", for: indexPath) as? PhotoListTableViewCell else {
            fatalError("dequeue cell fail")
        }
        cell.photoListCellViewModel = viewModel.getCellViewModel(at: indexPath)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        viewModel.userPressed(at: indexPath)
        
        if viewModel.isAllowSegue {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoDetailViewController, let url = viewModel.selectedPhoto?.image_url {
            vc.imageURL = url
        }
    }
    
}

class PhotoListTableViewCell: UITableViewCell {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var descContainerHeightConstraint: NSLayoutConstraint!
    var photoListCellViewModel : PhotoListCellViewModel? {
        didSet {
            nameLabel.text = photoListCellViewModel?.titleText
            descriptionLabel.text = photoListCellViewModel?.descText
            mainImageView.image(from: URL(string: photoListCellViewModel?.imageUrl ?? "")!)
            
            dateLabel.text = photoListCellViewModel?.dateText
        }
    }
}

extension UIImageView {
    
    func image(from imageURL: URL) {
        
        URLSession.shared.dataTask(with: imageURL) { data, response, error in
            if let error = error {
                print("\(error) occured")
                return
            }
            
            guard let data = data else {
                print("malformed data")
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.image = UIImage(data: data)
            }

        }.resume()
    }
}
