//
//  DemoAppDB.swift
//  DemoApp
//
//  Created by iMac on 03/06/22.
//

import Foundation
import UIKit
import SQLite

class DemoAppDB {
    
    private let demoApp = Table("demoApp")
    private let id = Expression<Int>("id")
    private let categoryId = Expression<String?>("categoryId")
    private let name = Expression<String?>("name")
    private let slug = Expression<String?>("slug")
    private let description = Expression<String?>("description")
    private let parentID = Expression<String?>("parentID")
    private let type = Expression<Int?>("type")
    private let attributeSet = Expression<String?>("attributeSet")
    private let categoryNumber = Expression<Int?>("categoryNumber")
    private let level = Expression<Int?>("level")
    private let featured = Expression<Bool?>("featured")
    private let icon = Expression<String?>("icon")
    private let image = Expression<String?>("image")
    private let status = Expression<Bool?>("status")
    private let create_date = Expression<String?>("create_date")
    
    static let instance = DemoAppDB()
    private var db: Connection?
    
    let destinationPath = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("newDemoAppDB.db")
    let sourcePath = Bundle.main.path(forResource: "newDemoAppDB", ofType: "db")
    
    private init() {
        do {
            db = try Connection(destinationPath)
            print(db)
            do {
                try db?.run(demoApp.create(ifNotExists: true) { t in
                    t.column(id, primaryKey: true)
                    t.column(categoryId)
                    t.column(slug)
                    t.column(name)
                    t.column(description)
                    t.column(parentID)
                    t.column(type)
                    t.column(attributeSet)
                    t.column(categoryNumber, unique: true)
                    t.column(level)
                    t.column(featured)
                    t.column(icon)
                    t.column(image)
                    t.column(status)
                    t.column(create_date)
                })
                if self.getDemoAppTable().count == 0 {
                    retrieveFromJsonFile()
                }
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func createDatabase() {
        let fileManger = FileManager.default
             print("destinationPath : = \(destinationPath)")
             print("sourcePath : = \(String(describing: sourcePath))")
             do{
                 if !fileManger.fileExists(atPath: destinationPath) {
                print(destinationPath)
            } else {
                print("data already created.")
            }
        }catch {
            print("error occurred, here are the details:\n \(error.localizedDescription)")
        }
    }
    
    func insertDataInDemoApp(data: NSDictionary, nameString: String) {
        guard let data = CategoryData.init(dictionary: data) else { return }
        do {
            try db?.run(demoApp.insert(categoryId <- data.categoryId, name <- nameString, slug <- data.slug, description <- data.description, parentID <- data.parentID, type <- data.type, attributeSet <- data.attributeSet, categoryNumber <- data.categoryNumber, level <- data.level, featured <- data.featured, icon <- data.icon, image <- data.image, status <- data.status, create_date <- data.create_date))
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getDemoAppTable() -> [CategoryData] {
        var demoApp = [CategoryData]()
        do {
            for item in try db!.prepare(self.demoApp) {
                let jsonobject = item[name]?.toJSON() as? NSArray
                print(item[slug] ?? "")
                if item[slug] == "Card " {
                    print(jsonobject)
                }
                let nameArray = Name.modelsFromDictionaryArray(array: jsonobject ?? [])
                demoApp.append(
                    CategoryData(categoryId: item[categoryId], name: nameArray, slug: item[slug], description: item[description], parentID: item[parentID], type: item[type], attributeSet: item[attributeSet], categoryNumber: item[categoryNumber], level: item[level], featured: item[featured], icon: item[icon], image: item[image], status: item[status], create_date: item[create_date]))
            }
        } catch {
            print(error)
        }
        return demoApp
    }
    
    func checkData() -> Bool {
        let query = self.demoApp.filter(self.categoryNumber == nil)
        do {
            for _ in try db!.prepare(query) {
                return true
            }
        } catch {
            print(error.localizedDescription)
        }
        return false
    }
    
    func retrieveFromJsonFile() {
        // Get the url of Persons.json in document directory
        guard let documentsDirectoryUrl = Bundle.main.url(forResource: "CategoryData", withExtension: ".json") else { return }
        //        let fileUrl = documentsDirectoryUrl.appendingPathComponent("Persons.json")
        
        // Read data from .json file and transform data into an array
        do {
            let data = try Data(contentsOf: documentsDirectoryUrl, options: [])
            guard let personArray = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else { return }
            if let data = personArray["data"] as? NSArray {
                
                for i in data {
                    if let dic = i as? NSDictionary{
                        if let nameArray = dic["name"] as? NSArray {
                            let jsonString = (json(from: nameArray) ?? "")
                            self.insertDataInDemoApp(data: dic, nameString: jsonString)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
}



