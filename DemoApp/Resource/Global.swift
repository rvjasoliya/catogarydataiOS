//
//  Global.swift
//  DemoApp
//
//  Created by iMac on 04/06/22.
//

import Foundation
import UIKit

func timeStamp() -> String{
    return "\(Int(Date().timeIntervalSince1970))"
}

func createDocument(folderName: String ,completion: @escaping(Bool,String)->()){
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
    if let documentsDirectory = path{
        let docDirectoryPath =  documentsDirectory.appending(folderName)
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: docDirectoryPath) {
            do {
                try fileManager.createDirectory(atPath: docDirectoryPath,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
                completion(true,docDirectoryPath)
                return
            } catch {
                print("Error creating folder in documents dir: \(error.localizedDescription)")
                completion(false,error.localizedDescription)
                return
            }
        }
        completion(true,docDirectoryPath)
    }
}

func saveImage(image: UIImage, imageName: String, documentDic: String) -> Bool {
    guard let data = image.jpegData(compressionQuality: 0.5) ?? image.pngData() else {
        return false
    }
    let fileManager = FileManager.default
    if fileManager.fileExists(atPath: documentDic) {
        if !fileManager.fileExists(atPath: documentDic+"/\(imageName)") {
            let url = URL(fileURLWithPath: documentDic)
            do {
                try data.write(to: url.appendingPathComponent(imageName))
                return true
            } catch {
                print(error.localizedDescription)
                return false
            }
        }
    }
    return false
}

func getImgsFromPath(path:String) -> UIImage? {
    let imageFile = fileInDocumentsDirectory(filename: path)
    return UIImage(contentsOfFile: imageFile)
}

func fileInDocumentsDirectory(filename: String) -> String {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent("image").appendingPathComponent(filename).path
    return fileURL
}
