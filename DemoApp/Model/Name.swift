//
//  Name.swift
//  DemoApp
//
//  Created by iMac on 02/06/22.
//

import Foundation


public class Name {
    public var _id : String?
    public var language : String?
    public var value : String?
    
    public class func modelsFromDictionaryArray(array:NSArray) -> [Name]
    {
        var models:[Name] = []
        for item in array
        {
            models.append(Name(dictionary: item as! NSDictionary)!)
        }
        return models
    }
    
    required public init?(dictionary: NSDictionary) {
        
        _id = dictionary["_id"] as? String
        language = dictionary["language"] as? String
        value = dictionary["value"] as? String
    }
    
    public func dictionaryRepresentation() -> NSDictionary {
        
        let dictionary = NSMutableDictionary()
        
        dictionary.setValue(self._id, forKey: "_id")
        dictionary.setValue(self.language, forKey: "language")
        dictionary.setValue(self.value, forKey: "value")
        
        return dictionary
    }
    
}
