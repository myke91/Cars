//
//  APIClient.swift
//  Cars
//
//  Created by Michael Dugah on 24/11/2021.
//

import Foundation
import RxCocoa
import RxSwift

fileprivate extension Encodable {
    var dictionaryValue:[String: Any?]? {
        guard let data = try? JSONEncoder().encode(self),
              let dictionary = try? JSONSerialization.jsonObject(with: data,options: .allowFragments) as? [String: Any] else {
                  return nil
              }
        return dictionary
    }
}

class APIClient {
    static var shared = APIClient()
    lazy var requestObservable = RequestObservable(config: .default)
    
    func fetchCars() throws -> Observable<[String: AnyObject]> {
        guard let requestUrl = URL(string: ARTICLES_URL) else{
            fatalError("Malformed URL")
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = RequestType.GET.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return requestObservable.callAPI(request: request)
    }
    
}
