//
//  PhotoListViewModel.swift
//  MVVMUnitTest
//
//  Created by Jin Lee on 21/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import Foundation

struct PhotoListCellViewModel {
    let titleText: String
    let descText: String
    let imageUrl: String
    let dateText: String
}

class PhotoListViewModel {
    let apiService: APIServiceProtocol
    private var photos: [Photo] = []

    private var cellViewModels: [PhotoListCellViewModel] = [PhotoListCellViewModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    var selectedPhoto: Photo?
    var isAllowSegue = false
    
    func getCellViewModel(at indexPath: IndexPath) -> PhotoListCellViewModel {
        return cellViewModels[indexPath.row]
    }
    
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    
    var alertMessage: String = "" {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    var reloadTableViewClosure: (() -> Void)?
    var updateLoadingStatus: (() -> Void)?
    var showAlertClosure: (() -> Void)?
    
    
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    func initFetch() {
        self.isLoading = true
        
        apiService.fetchPopularPhoto { [weak self] (success, photos, error) in
            self?.isLoading = false
            if let error = error {
                self?.alertMessage = error.rawValue
            } else {
                self?.processFetchedPhoto(photos: photos)
            }
            
        }
    }
    
    func createCellViewModel( photo: Photo ) -> PhotoListCellViewModel {

        //Wrap a description
        var descTextContainer: [String] = [String]()
        if let camera = photo.camera {
            descTextContainer.append(camera)
        }
        if let description = photo.description {
            descTextContainer.append( description )
        }
        let desc = descTextContainer.joined(separator: " - ")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return PhotoListCellViewModel( titleText: photo.name,
                                       descText: desc,
                                       imageUrl: photo.image_url,
                                       dateText: dateFormatter.string(from: photo.created_at) )
    }
    
    func userPressed(at indexPath: IndexPath) {
        let photo = photos[indexPath.row]
        
        if photo.for_sale {
            isAllowSegue = true
            selectedPhoto = photo
        } else {
            isAllowSegue = false
            selectedPhoto = nil
            alertMessage = "This item is not for sale"
        }
    }
    
    private func processFetchedPhoto( photos: [Photo] ) {
        self.photos = photos // Cache
        var vms = [PhotoListCellViewModel]()
        for photo in photos {
            vms.append( createCellViewModel(photo: photo) )
        }
        self.cellViewModels = vms
    }
}
