//
//  APIService.swift
//  MVVMUnitTest
//
//  Created by Jin Lee on 21/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import Foundation

enum APIError: String, Error {
    case noNetwork = "No Network"
    case serverOverload = "Server is overloaded"
    case permissionDenied = "You don't have permission"
}

protocol APIServiceProtocol {
    func fetchPopularPhoto( complete: @escaping ( _ success: Bool, _ photos: [Photo], _ error: APIError? )->() )
}

class APIService: APIServiceProtocol {
    func fetchPopularPhoto(complete: @escaping (Bool, [Photo], APIError?) -> ()) {
        DispatchQueue.global().async {
            sleep(3)
            let path = Bundle.main.path(forResource: "content", ofType: "json")!
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let photos = try! decoder.decode(Photos.self, from: data)
            complete(true, photos.photos, nil)
        }
    }
    
    
}
