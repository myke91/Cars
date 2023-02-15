//
//  CarsUITests.swift
//  CarsUITests
//
//  Created by Michael Dugah on 22/11/2021.
//

import XCTest

class CarsUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
        super.tearDown()
    }
    
    
    func testUICollectionViewPresent() throws {
        XCTAssertTrue(uiCollectionView.exists)
    }
    
    func testNumberOfItemsPerRowInUICollectionView() throws {
        XCTAssertGreaterThan(uiCollectionView.cells.count, 1)
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    // MARK: - Element Helper
    var uiCollectionView: XCUIElement {
        return app.collectionViews.element
    }
    
}
