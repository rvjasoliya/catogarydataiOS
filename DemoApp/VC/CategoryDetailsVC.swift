//
//  CategoryDetailsVC.swift
//  DemoApp
//
//  Created by iMac on 03/06/22.
//

import UIKit

class CategoryDetailsVC: UIViewController {

    @IBOutlet weak var hindiNameTF: UITextField!
    @IBOutlet weak var englishNameTF: UITextField!
    @IBOutlet weak var decriptionTV: UILabel!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    @IBOutlet weak var imageStackView: UIStackView!
    
    var categoryData:CategoryData?
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSetup()
    }
    
    func dataSetup(){
        if let categoryData = categoryData {
            decriptionTV.text = categoryData.description
            for i in categoryData.name ?? [] {
                if i.language == "en" {
                    self.englishNameTF.text = i.value
                }
                
                if i.language == "hi" {
                    self.hindiNameTF.text = i.value
                }
            }//URL(string: "\(categoryData.image?.split(separator: ",").first ?? "")")?.lastPathComponent
            
            for i in categoryData.image?.split(separator: ",") ?? []{
                let str = "\(i)"
                print(getImgsFromPath(path: str))
                if let image = getImgsFromPath(path: str){
                    self.images.append(image)
                }
            }
            imageStackView.isHidden = images.count == 0
            imageCollectionView.reloadData()
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
}

extension CategoryDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        cell.removeBtn.tag = indexPath.row
        cell.removeBtn.isHidden = true
        cell.imageView.image = self.images[indexPath.row]
        cell.imageView.contentMode = .scaleAspectFill
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
