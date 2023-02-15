//
//  CarSpecs.swift
//  Cars
//
//  Created by Michael Dugah on 23/11/2021.
//

import UIKit
import RealmSwift


class CarModel: Object, Codable {
    @objc dynamic var _id = ""
    @objc dynamic var title: String = ""
    @objc dynamic var imageLocation: String = ""
    @objc dynamic var dateTime: String = ""
    @objc dynamic var desc: String = ""
    var photo: Image
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    func getDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // setting locale to reliable US_POSIX
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        guard let date = dateFormatter.date(from: dateTime) else {
            return ""
        }
        
        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)
        
        guard let timeFormatter : String = DateFormatter.dateFormat(fromTemplate: "j", options:0, locale: Locale.current) else {
            return ""
        }
        
        if(year == dateFormatter.string(from: Date())){
            if timeFormatter.contains("a") {
                //phone is set to 12 hours
                dateFormatter.dateFormat = "dd MMMM, h:mm a"
                return dateFormatter.string(from: date)
            } else {
                //phone is set to 24 hours
                dateFormatter.dateFormat = "dd MMMM, HH:mm"
                return dateFormatter.string(from: date)
            }
        }else{
            if timeFormatter.contains("a") {
                //phone is set to 12 hours
                dateFormatter.dateFormat = "dd MMMM yyyy, h:mm a"
                return dateFormatter.string(from: date)
            } else {
                //phone is set to 24 hours
                dateFormatter.dateFormat = "dd MMMM yyyy, HH:mm"
                return dateFormatter.string(from: date)
            }
        }
    }
}


//MARK: Codable Image struct
struct Image: Codable{
    let imageData: Data?
    
    init(withImage image: UIImage) {
        self.imageData = image.pngData()
    }
    
    func getImage() -> UIImage? {
        guard let imageData = self.imageData else {
            return nil
        }
        let image = UIImage(data: imageData)
        
        return image
    }
}
