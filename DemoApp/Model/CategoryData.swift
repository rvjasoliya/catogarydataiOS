//
//  CategoryData.swift
//  DemoApp
//
//  Created by iMac on 02/06/22.
//

import Foundation


public class CategoryData {
    public var categoryId : String?
    public var name : Array<Name>?
    public var slug : String?
    public var description : String?
    public var parentID : String?
    public var type : Int?
    public var attributeSet : String?
    public var categoryNumber : Int?
    public var level : Int?
    public var featured : Bool?
    public var icon : String?
//    public var image : Array<String>?
    public var image : String?
    public var status : Bool?
    public var create_date : String?
    
    init(categoryId : String?, name : Array<Name>?, slug : String?, description : String?, parentID : String?, type : Int?, attributeSet : String?, categoryNumber : Int?, level : Int?, featured : Bool?, icon : String?, image : String?, status : Bool?, create_date : String?) {
        self.categoryId = categoryId
        self.name = name
        self.slug = slug
        self.description = description
        self.parentID = parentID
        self.type = type
        self.attributeSet = attributeSet
        self.categoryNumber = categoryNumber
        self.level = level
        self.featured = featured
        self.icon = icon
        self.image = image
        self.status = status
        self.create_date = create_date
    }
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [CategoryData]
    {
        var models:[CategoryData] = []
        for item in array
        {
            models.append(CategoryData(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        categoryId = dictionary["categoryId"] as? String
        if let data = dictionary["name"] as? NSArray {
            name = Name.modelsFromDictionaryArray(array: data)
        }
        slug = dictionary["slug"] as? String
        description = dictionary["description"] as? String
        parentID = dictionary["parentID"] as? String
        type = dictionary["type"] as? Int
        attributeSet = dictionary["attributeSet"] as? String
        categoryNumber = dictionary["categoryNumber"] as? Int
        level = dictionary["level"] as? Int
        featured = dictionary["featured"] as? Bool
        icon = dictionary["icon"] as? String
        image = dictionary["image"] as? String
//        if let data = (dictionary["image"] as? [String]) {
//            image = data
//        }
        //        if (dictionary["image"] != nil) { image =  }
        status = dictionary["status"] as? Bool
        create_date = dictionary["create_date"] as? String
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self.categoryId, forKey: "categoryId")
        dictionary.setValue(self.slug, forKey: "slug")
        dictionary.setValue(self.description, forKey: "description")
        dictionary.setValue(self.parentID, forKey: "parentID")
        dictionary.setValue(self.type, forKey: "type")
        dictionary.setValue(self.attributeSet, forKey: "attributeSet")
        dictionary.setValue(self.categoryNumber, forKey: "categoryNumber")
        dictionary.setValue(self.level, forKey: "level")
        dictionary.setValue(self.featured, forKey: "featured")
        dictionary.setValue(self.icon, forKey: "icon")
        dictionary.setValue(self.status, forKey: "status")
        dictionary.setValue(self.image, forKey: "image")
        dictionary.setValue(self.create_date, forKey: "create_date")
        
        return dictionary
    }    
}

public class MainData {
    public var data : Array<CategoryData>?

    public class func modelsFromDictionaryArray(array:NSArray) -> [MainData]
    {
        var models:[MainData] = []
        for item in array
        {
            models.append(MainData(dictionary: item as! NSDictionary)!)
        }
        return models
    }

    required public init?(dictionary: NSDictionary) {
        if let data1 = dictionary["data"] as? NSArray {
            data = CategoryData.modelsFromDictionaryArray(array: data1)
        }
    }

    public func dictionaryRepresentation() -> NSDictionary {

        let dictionary = NSMutableDictionary()


        return dictionary
    }

}
