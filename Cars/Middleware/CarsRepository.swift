//
//  CarsAPI.swift
//  Cars
//
//  Created by Michael Dugah on 23/11/2021.
//



import UIKit
import RealmSwift
import RxSwift


class CarsRepository {
    enum Error: Swift.Error {
        case unknownAPIResponse
        case generic
        case malformedUrl
    }
    
    private let disposeBag = DisposeBag()
    
    func fetchCars(completion: @escaping (Result<[CarModel], Swift.Error>) -> Void) {
        guard URL(string: ARTICLES_URL) != nil else{
            completion(.failure(Error.malformedUrl))
            return
        }
        
        let client = APIClient.shared
        do {
            try client.fetchCars().subscribe(
                onNext: { result in
                    guard
                        let status = result["status"] as? String
                    else {
                        completion(.failure(Error.unknownAPIResponse))
                        return
                    }
                    
                    switch status {
                    case "success":
                        NSLog("Results processed OK")
                    case "fail":
                        completion(.failure(Error.generic))
                        return
                    default:
                        completion(.failure(Error.unknownAPIResponse))
                        return
                    }
                    
                    guard
                        let responseReceived = result["content"] as? [[String: AnyObject]]
                    else {
                        completion(.failure(Error.unknownAPIResponse))
                        return
                    }
                    let serverTime = result["serverTime"] as? Int
                    self.takeServerTimeSnapshot(time: serverTime)
                    
                    let carsSpecs = self.getCarSpecs(apiData: responseReceived)
                    completion(.success(carsSpecs))
                },
                onError: { error in
                    NSLog(error.localizedDescription)
                },
                onCompleted: {
                    NSLog("Completed event.")
                }).disposed(by: disposeBag)
        }
        catch{
        }
        
        
        
    }
    
    private func getCarSpecs(apiData: [[String: AnyObject]]) -> [CarModel] {
        let cars: [CarModel] = apiData.compactMap { data in
            guard
                let title = data["title"] as? String,
                let imageLocation = data["image"] as? String,
                let dateTime = data["dateTime"] as? String,
                let description = data["ingress"] as? String
            else {
                return nil
            }
            
            
            guard
                let url =  URL(string: imageLocation),
                let imageData = try? Data(contentsOf: url as URL)
            else {
                return nil
            }
            
            if let image = UIImage(data: imageData) {
                let carSpec = CarModel()
                
                carSpec._id = UUID().uuidString
                carSpec.title = title
                carSpec.imageLocation = imageLocation
                carSpec.dateTime = dateTime
                carSpec.desc = description
                carSpec.photo = Image(withImage: image)
                return carSpec
            } else {
                return nil
            }
        }
        return cars
    }
    
    public func persistCarRecords(records: [CarModel]){
        do{
            let realm = try Realm()
            try realm.write() {
                for  record in records {
                    realm.add(record)
                }
            }
            
        }catch{
            NSLog("Error persisting offline records")
        }
    }
    
    public func retrieveCars() -> [CarModel]{
        do{
            let realm = try Realm()
            let results = realm.objects(CarModel.self)
            let cars: [CarModel] = Array(results).compactMap { data in
                
                guard
                    let url =  URL(string: data.imageLocation),
                    let imageData = try? Data(contentsOf: url as URL)
                else {
                    return nil
                }
                
                if let image = UIImage(data: imageData) {
                    data.photo = Image(withImage: image)
                    return data
                } else {
                    return nil
                }
            }
            return cars
        }catch{
            NSLog("Error retrieving offline records")
        }
        return []
    }
    
    public func offlineRecordCount() -> Int{
        do{
            let realm = try Realm()
            let results = realm.objects(CarModel.self)
            return results.count
        }catch{
            NSLog("Error retrieving offline records")
        }
        return 0
    }
    
    private func takeServerTimeSnapshot(time: Int?){
        guard let serverTime = time else {
            return
        }
        
        UserDefaults.standard.set(serverTime, forKey: "sevenpeakssoftware.cars.serverTime")
    }
    
    public func timeElapsedSinceLastFetch() -> Int{
        let serverTime = UserDefaults.standard.integer(forKey: "sevenpeakssoftware.cars.serverTime")
        
        if(serverTime == 0){
            return 0
        }
        
        let diff = Int(Date().timeIntervalSince1970 - TimeInterval(serverTime))
        
        let hours = diff / 3600
        let minutes = (diff - hours * 3600) / 60
        return minutes
    }
}

extension Date {
    var millisecondsSince1970:Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
