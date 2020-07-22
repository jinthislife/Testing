//
//  PhotoListViewModelTests.swift
//  MVVMUnitTestTests
//
//  Created by Jin Lee on 21/7/20.
//  Copyright © 2020 Jin Lee. All rights reserved.
//

import XCTest
@testable import MVVMUnitTest

class MockAPIService: APIServiceProtocol {
    var isFetchPopoularPhotoCalled = false
    var fetchedPhotos: [Photo] = [Photo]()
    var completionClosure: ((Bool, [Photo], APIError?) -> Void)?
    
    func fetchPopularPhoto(complete: @escaping (Bool, [Photo], APIError?) -> Void) {
        isFetchPopoularPhotoCalled = true
        completionClosure = complete
    }
    
    func fetchFail(error: APIError?) {
        completionClosure?(false, fetchedPhotos, error)
    }
    
    func fetchSuccess() {
        completionClosure?(true, fetchedPhotos, nil)
    }
}

class PhotoListViewModelTests: XCTestCase {
    
    private var sut: PhotoListViewModel!
    private var mockAPIService: MockAPIService!
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        sut = PhotoListViewModel(apiService: mockAPIService)
    }
    
    override func tearDown() {
        sut = nil
        mockAPIService = nil
        super.tearDown()
    }
    
    func test_fetch_photo() {
        XCTAssertFalse(mockAPIService.isFetchPopoularPhotoCalled)
        sut.initFetch()
        XCTAssertTrue(mockAPIService.isFetchPopoularPhotoCalled)
    }
    
    func test_fetch_photo_fail() {
        // given
        let error = APIError.permissionDenied
        
        // when
        sut.initFetch()
        mockAPIService.fetchFail(error: error)
        
        // then
        XCTAssertEqual(sut.alertMessage, error.rawValue)
    }
    
    func test_loading_when_fetching() {
        var loadingStatus = false
        
        let loadingExpectation = expectation(description: "loading started")
        let finishedExpectation = expectation(description: "loading finished")

        
        sut.updateLoadingStatus = { [weak sut] in
            DispatchQueue.main.async {
                loadingStatus = sut!.isLoading
                if sut!.isLoading {
                    loadingExpectation.fulfill()
                } else {
                    finishedExpectation.fulfill()
                }
            }
        }
        
        sut.initFetch()
        wait(for: [loadingExpectation], timeout: 0.1)
        XCTAssertTrue(loadingStatus)
        
        mockAPIService.fetchSuccess()
        wait(for: [finishedExpectation], timeout: 0.1)
        XCTAssertFalse(loadingStatus)
    }

    func test_userPressForSaleItem() {
        fetchAndLoadPhotos()
        
        sut.userPressed(at: IndexPath(row: 0, section: 0))
        
        
        XCTAssertTrue(sut.isAllowSegue)
        XCTAssertNotNil(sut.selectedPhoto)
    }
    
    func test_userPressForNoSaleItem() {
        // given
        fetchAndLoadPhotos()
        
        let expect = expectation(description: "Alert message shown")
        
        sut.showAlertClosure = { [weak sut] in
            expect.fulfill()
            XCTAssertEqual(sut!.alertMessage, "This item is not for sale")
        }
        
        //when
        sut.userPressed(at: IndexPath(row: 4, section: 0))
        
        //then
        XCTAssertFalse(sut.isAllowSegue)
        XCTAssertNil(sut.selectedPhoto)
        
        waitForExpectations(timeout: 0.01)
    }
    
    func test_createCellViewModels() {
        let photos = StubGenerator().stubPhotos()
        mockAPIService.fetchedPhotos = photos
        sut.initFetch()
        mockAPIService.fetchSuccess()
        
        XCTAssertEqual(photos.count, sut.numberOfCells)
    }
    
    func test_getCellViewModel() {
        fetchAndLoadPhotos()
        
        let indexPath = IndexPath(row: 1, section: 0)
        let testPhoto = mockAPIService.fetchedPhotos[indexPath.row]
        
        let cvm = sut.getCellViewModel(at: indexPath)
        
        XCTAssertEqual(cvm.titleText, testPhoto.name)
    }
    
    func test_cellViewModel() {
        let today = Date()
        let photo = Photo(id: 1, name: "Name", description: "Desc", created_at: today, image_url: "url", for_sale: true, camera: "camera")
        let cellViewModel = sut.createCellViewModel(photo: photo)
        
        let year = Calendar.current.component(.year, from: today)
        let month = Calendar.current.component(.month, from: today)
        let day = Calendar.current.component(.day, from: today)
        
        // assert
        XCTAssertEqual(photo.name, cellViewModel.titleText)
        XCTAssertEqual(photo.image_url, cellViewModel.imageUrl)
        XCTAssertEqual(cellViewModel.dateText, String(format: "%d-%02d-%02d", year, month, day))
    }
    
    func fetchAndLoadPhotos() {
        mockAPIService.fetchedPhotos = StubGenerator().stubPhotos()
        sut.initFetch()
        mockAPIService.fetchSuccess()
    }
}

class StubGenerator {
    func stubPhotos() -> [Photo] {
        let url = Bundle.main.url(forResource: "content", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let photos = try! decoder.decode(Photos.self, from: data)
        return photos.photos
    }
}
