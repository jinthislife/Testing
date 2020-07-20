//
//  Alamofire+extensions.swift
//  ThirdPartyDependencyTestable
//
//  Created by Jin Lee on 20/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import Alamofire

extension Alamofire.DataResponse {
    public var serviceResponse: ServiceResponse {
        switch self.result {
        case .success(let value):
            print(value)
            if let data = value as? Data {
                return ServiceResponse.success(data)
            } else {
                return ServiceResponse.failure("Did not receive JSON response")
            }
        case .failure(let error):
            return ServiceResponse.failure("\(error.localizedDescription)")
        }
    }
}
