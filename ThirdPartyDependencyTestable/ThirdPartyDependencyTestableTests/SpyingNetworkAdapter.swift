//
//  SpyingNetworkAdapter.swift
//  ThirdPartyDependencyTestableTests
//
//  Created by Jin Lee on 20/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import Foundation
@testable import ThirdPartyDependencyTestable

class SpyingNetworkAdapter: NetworkAdapter {
    
    var postWasCalled = false
    var destination: String? = nil
    var payload: [String: Any]? = nil
    var postArgsResponseHandler: [(ServiceResponse) -> Void] = []

    func post(destination: String, payload: [String : Any]?, responseHandler: @escaping (ServiceResponse) -> Void) {
        self.postWasCalled = true
        self.destination = destination
        self.payload = payload
        self.postArgsResponseHandler.append(responseHandler)
    }
}
