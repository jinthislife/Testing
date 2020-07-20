//
//  AFNetworkAdapter.swift
//  ThirdPartyDependencyTestable
//
//  Created by Jin Lee on 20/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import Alamofire

public typealias jsonResponse = [String: Any]

public enum ServiceResponse {
    case success(Data)
    case failure(String)
}

public protocol NetworkAdapter {
    func post(destination: String, payload: [String: Any]?, responseHandler: @escaping (ServiceResponse) -> Void)
}

public class AFNetworkAdapter: NetworkAdapter {
    public func post(destination: String, payload: [String : Any]?, responseHandler: @escaping (ServiceResponse) -> Void) {
        AF.request(destination)
            .response {
                response in
                responseHandler(response.serviceResponse)
        }
    }
    
    
}
