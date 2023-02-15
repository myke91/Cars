//
//  RequestObservable.swift
//  Cars
//
//  Created by Michael Dugah on 24/11/2021.
//
import Foundation
import RxSwift
import RxCocoa

public class RequestObservable {
    private lazy var jsonDecoder = JSONDecoder()
    private var urlSession: URLSession
    public init(config: URLSessionConfiguration = URLSessionConfiguration.default) {
        urlSession = URLSession(configuration: config)
    }
    
    
    
    public func callAPI(request: URLRequest) -> Observable<[String: AnyObject]> {
        return Observable.create { observer in
            let task = self.urlSession.dataTask(with: request) { (data, response, error) in
                if let httpResponse = response as? HTTPURLResponse {
                    let statusCode = httpResponse.statusCode
                    do {
                        let _data = data ?? Data()
                        if (200...399).contains(statusCode) {
                            let resultsDictionary = try JSONSerialization.jsonObject(with: _data) as? [String: AnyObject]
                            if let result = resultsDictionary {
                                observer.onNext(result)
                            }
                        }
                        else {
                            if let error = error {
                                observer.onError(error)
                            }
                        }
                    } catch {
                        observer.onError(error)
                    }
                }
                observer.onCompleted()
            }
            task.resume()
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
