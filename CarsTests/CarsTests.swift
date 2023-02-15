//
//  CarsTests.swift
//  CarsTests
//
//  Created by Michael Dugah on 22/11/2021.
//

import XCTest
@testable import Cars
@testable import RealmSwift

class CarsTests: XCTestCase {
    var urlSession: URLSession!
    var car: CarModel!
    var carService: CarsRepository!
    var car1: CarModel!
    var car2: CarModel!
    
    override func setUpWithError() throws {
        urlSession = URLSession(configuration: .default)
        car = CarModel()
        car1 = CarModel()
        car2 = CarModel()
        carService = CarsRepository()
        try super.setUpWithError()
        
    }
    
    override func tearDownWithError() throws {
        urlSession = nil
        car = nil
        carService = nil
        try super.tearDownWithError()
    }
    
    func testCarSpecsDateDisplay() throws {
        
        car._id = UUID().uuidString
        car.title = "Q7 - Greatness starts, when you don't stop."
        car.imageLocation = "https://www.apphusetreach.no/sites/default/files/audi_q7.jpg"
        car.dateTime = "25.05.2018 14:13"
        car.desc = "The Audi Q7 is the result of an ambitious idea: never cease to improve."
        
        let result = car.getDate()
        let format1 = "25 May 2018, 14:13"
        let format2 = "25 May 2018, 2:13 PM"
        
        XCTAssert(result.isEqual(format1) || result.isEqual(format2))
    }
    
    func testOnlineFetch() throws {
        let urlString = "https://www.apphusetreach.no/application/119267/article/get_articles_list"
        let url = URL(string: urlString)!
        let promise = expectation(description: "Completion handler invoked")
        var statusCode: Int?
        var responseError: Error?
        
        
        let dataTask = urlSession.dataTask(with: url) { _, response, error in
            statusCode = (response as? HTTPURLResponse)?.statusCode
            responseError = error
            promise.fulfill()
        }
        dataTask.resume()
        wait(for: [promise], timeout: 5)
        
        
        XCTAssertNil(responseError)
        XCTAssertEqual(statusCode, 200)
    }
}
