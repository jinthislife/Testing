//
//  ModelController.swift
//  ThirdPartyDependencyTestable
//
//  Created by Jin Lee on 20/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import Foundation

class ModelController {
    
    let url: String
    var networkAdapter: NetworkAdapter = AFNetworkAdapter()
    var feeds: [Feed] = [] {
        didSet {
            handleResults(feeds)
        }
    }
    
    var handleResults: (([Feed]) -> Void) = {
        print("\($0.count) feeds received")
    }
    
    init(baseUrl: String = "https://www.reddit.com/r/humor.json") {
        self.url = baseUrl
    }
    
    func fetchFeed(responseHandler: @escaping (String?) -> Void) {
//        let parameters: Parameters = ["id": "userID","service": "token"]
        
        networkAdapter.post(destination: url, payload: nil) { [weak self] serviceResponse in
            switch serviceResponse {
            case .success(let data):
                guard let decoded = try? JSONDecoder().decode(RedditResponse.self, from: data) else {
                    responseHandler("decode error")
                    return
                }
                self?.feeds = decoded.feeds
                responseHandler(nil)
                
            case .failure(let error):
                responseHandler(error)
            }
            
        }
        
        #if false
        AF.request(createOrderEndpoint, method: .get, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch response.result {
                case .success:
                    ()
                default:
                    ()
                }
        }
        #endif
    }
    
    func buildResponseHandler() -> ((ServiceResponse) -> Void) {
        return { response in
            print(String(describing: response))
        }
    }
}
