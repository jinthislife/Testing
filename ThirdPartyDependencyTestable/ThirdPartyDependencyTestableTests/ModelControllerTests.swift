//
//  ModelControllerTests.swift
//  ThirdPartyDependencyTestableTests
//
//  Created by Jin Lee on 20/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import XCTest
@testable import ThirdPartyDependencyTestable

class ModelControllerTests: XCTestCase {
    
    private var sut: ViewController!
    private var spyNetworkAdapter: SpyingNetworkAdapter!
    private let requestUrl = "https://www.reddit.com/r/humor.json"
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: String(describing: ViewController.self))
        
        spyNetworkAdapter = SpyingNetworkAdapter()
        sut.modelController = ModelController()
        sut.modelController.networkAdapter = spyNetworkAdapter
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        spyNetworkAdapter = nil
        super.tearDown()
    }

    func test_networkRequest() {
        XCTAssertTrue(spyNetworkAdapter.postWasCalled)
        XCTAssertEqual(spyNetworkAdapter.destination, requestUrl)
        XCTAssertNotEqual(spyNetworkAdapter.destination, "")
    }

    
    /// <#Description#>
    func test_networkSuccessResponse() {
        let testBundle = Bundle(for: type(of: self))
        
        guard let url = testBundle.url(forResource: "redditResponse", withExtension: "json") else {
            XCTFail("Test Json file is missing")
            return
        }
        
        guard let data = try? Data(contentsOf: url) else {
            XCTFail("Could not load data from redditResponse.json")
            return
        }
        
        let exp = expectation(description: "success response received")

        sut.modelController.handleResults = { _ in
            exp.fulfill()
        }
        
        DispatchQueue.global().async { [weak self] in
            self?.spyNetworkAdapter.postArgsResponseHandler.first?(ServiceResponse.success(data))
        }
        
        wait(for: [exp], timeout: 0.01)
        XCTAssertEqual(sut.modelController.feeds.count, 25)
    }
    
    #if false
    func test_networkFailureResponse() {
                let successData: jsonResponse = ["orderId": "123"]
        //        let errors: JsonErrors = [["itemNumber": "Invalid"], ["customerId": "Invalid"]]
        let failureMessage = "Failed to communicate with server"
    }
    #endif
}

