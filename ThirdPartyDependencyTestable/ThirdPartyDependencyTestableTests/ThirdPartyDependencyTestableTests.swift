//
//  ThirdPartyDependencyTestableTests.swift
//  ThirdPartyDependencyTestableTests
//
//  Created by Jin Lee on 20/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import XCTest
@testable import ThirdPartyDependencyTestable

class MockModelController: ModelController {
    var responseHandler: ((String?) -> Void)?
    
    override func fetchFeed(responseHandler: @escaping (String?) -> Void) {
        self.responseHandler = responseHandler
    }
}


class ViewControllerTests: XCTestCase {
    
    private var sut: ViewController!
    private var mockModelController: MockModelController!

    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: String(describing: ViewController.self))
        mockModelController = MockModelController()
        mockModelController.networkAdapter = SpyingNetworkAdapter()
        sut.modelController = mockModelController
        
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    
    func test_viewDidLoad_withFetchError_shouldShowErrorAelrt() {
        let exp = expectation(description: "expecting error alert")
        mockModelController.responseHandler?("error message")
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        
        if result == .timedOut {
            XCTAssertFalse(sut.isTableViewLoaded)
        } else {
            XCTFail("Delay interrupted")
        }
    }
    
    func test_viewDidLoad_withEmptyError_shouldLoadTableView() {
        let exp = expectation(description: "set isTableViewLoad true")
        
        mockModelController.responseHandler?(nil)
        
        let result = XCTWaiter.wait(for: [exp], timeout: 0.1)
        
        if result == .timedOut {
            XCTAssertTrue(sut.isTableViewLoaded)
        } else {
            XCTFail("Delay interrupted")
        }
    }
}

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
