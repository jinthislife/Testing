//
//  ViewControllerTests.swift
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
