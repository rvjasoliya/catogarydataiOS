//
//  AddCategoryVC.swift
//  DemoApp
//
//  Created by iMac on 03/06/22.
//

import UIKit

protocol AddCategoryDelgate{
    func saveButton(_ viewController: AddCategoryVC, didSave button: UIButton)
    func cancelButton(_ viewController: AddCategoryVC, didCancel button: UIButton)
}

class AddCategoryVC: UIViewController {
    
    @IBOutlet weak var categoryNameTF: UITextField!
    @IBOutlet weak var hindiCategorynameTF: UITextField!
    @IBOutlet weak var descriptionTV: UITextView! {
        didSet {
            descriptionTV.delegate = self
        }
    }
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
        }
    }
    
    var placeholderLabel = UILabel()
    var delegate: AddCategoryDelgate?
    var images: [UIImage] = []
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        placeholderLabel.text = "Write to Us..."
        placeholderLabel.font = UIFont(name: "Menlo", size: 16)
        placeholderLabel.sizeToFit()
        descriptionTV.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 15, y: (descriptionTV.font?.pointSize)! / 2)
        placeholderLabel.textColor = .lightGray
    }
    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let data = mainData.sorted(by: {($0.categoryNumber ?? 0) < ($1.categoryNumber ?? 0)})
        let categoryNumber = (data.last?.categoryNumber ?? 0)+1
        let date = Date().formatted(.iso8601).stringByDecodingURL
        let nameArray:[[String: Any]] = [
            ["_id": "\(randomKeyGenerates(length: 24))","value": categoryNameTF.text ?? "","language": "en"],
            ["_id": "\(randomKeyGenerates(length: 24))","value": hindiCategorynameTF.text ?? "","language": "hi"]
        ]
        
        let dic: NSDictionary = [
            "categoryId" : randomKeyGenerates(length: 24),
            "slug" : categoryNameTF.text ?? "",
            "description" : descriptionTV.text ?? "",
            "parentID" : "0",
            "type" : 2,
            "attributeSet" : randomKeyGenerates(length: 24),
            "categoryNumber" : categoryNumber,
            "level" : 0,
            "featured" : false,
            "icon" : "",
            "image" : saveImagePath(),
            "status" : true,
            "create_date" : date
        ]
        print(dic)
        DemoAppDB.instance.insertDataInDemoApp(data: dic, nameString: nameArray.jsonString() ?? "")
        self.dismiss(animated: true)
        self.delegate?.saveButton(self, didSave: sender)
    }
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
        self.delegate?.cancelButton(self, didCancel: sender)
    }
    
    func saveImagePath() -> String {
        var imagePathArr: [String] = []
        for image in images {
            createDocument(folderName: "/image") { status, path in
                if status {
                    let uuid = UUID().uuidString
                    let _ = saveImage(image: image, imageName: uuid + ".jpeg", documentDic: path)
                    let imagePath = "/" + uuid + ".jpeg"
                    print(imagePath)
                    imagePathArr.append(imagePath)
                }
            }
        }
        return imagePathArr.joined(separator: ",")
    }
    
    func uploadImage() {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "ChooseExisting", style: .default) { (action) in
            self.openPhotos()
        }
        let okAction2 = UIAlertAction(title: "TakePhoto", style: .default) { (action) in
            self.openCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(okAction2)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = imageCollectionView
        alertController.popoverPresentationController?.sourceRect = imageCollectionView.frame
        self.present(alertController, animated: true, completion: nil)
    }
}

extension AddCategoryVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count+1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.delegate = self
        cell.removeBtn.tag = indexPath.row
        cell.removeBtn.isHidden = indexPath.row == 0 ? true : false
        if indexPath.row == 0 {
            cell.imageView.image = UIImage(named: "ic_add_photo")
            cell.imageView.contentMode = .scaleAspectFit
        }else{
            cell.imageView.image = self.images[indexPath.row-1]
            cell.imageView.contentMode = .scaleAspectFill
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if indexPath.row == 0{
            uploadImage()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}

extension AddCategoryVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}

extension AddCategoryVC: ImageCellDelegate {
    func removeButton(_ sender: UIButton) {
        self.view.endEditing(true)
        self.images.remove(at: sender.tag-1)
        self.imageCollectionView.reloadData()
    }
    
    
}

//MARK: ImagePicker Delegate Methods
extension AddCategoryVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        self.images.append(image)
        self.imageCollectionView.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.view.endEditing(true)
        picker.dismiss(animated: true)
    }
    
    func openCamera(){
        if(UIImagePickerController.isSourceTypeAvailable(.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }else{
            let alert  = UIAlertController(title: NSLocalizedString("warning", comment: ""), message: "Not Found Camera!.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openPhotos(){
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
}


extension Array {
    func jsonString() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        guard jsonData != nil else {return nil}
        let jsonString = String(data: jsonData!, encoding: .utf8)
        guard jsonString != nil else {return nil}
        return jsonString
    }

}

extension Collection where Iterator.Element == [String:AnyObject] {
    func toJSONString(options: JSONSerialization.WritingOptions = .prettyPrinted) -> String {
        if let arr = self as? [[String:AnyObject]],
            let dat = try? JSONSerialization.data(withJSONObject: arr, options: options),
            let str = String(data: dat, encoding: String.Encoding.utf8) {
            return str
        }
        return "[]"
    }
}
