//
//  ViewController.swift
//  DemoApp
//
//  Created by iMac on 02/06/22.
//

import UIKit

var mainData:[CategoryData] = []

class CategoryListVC: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellReuseIdentifier: "CategoryCell")
        }
    }
    @IBOutlet weak var addButton: UIButton!
    
    var mainCategoryData: [CategoryData] = []
    var selectedCategoryData: [CategoryData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchTextField.delegate = self
        
        print(mainData.count)
        print(randomKeyGenerates(length: 24))
        setupData()       
    }
    
    @IBAction func addButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddCategoryVC") as! AddCategoryVC
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    func setupData(){
        mainCategoryData = mainData.filter({$0.parentID == "0"}).sorted(by: {($0.slug ?? "") < ($1.slug ?? "")})
        self.tableView.reloadData()
    }
    
//    func saveToDiorectory(){
//        guard let documentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//        let fileUrl = documentDirectoryUrl.appendingPathComponent("CategoryData.json")
//        guard let documentsDirectoryUrl = Bundle.main.url(forResource: "CategoryData", withExtension: ".json") else { return }
//        do {
//            let data = try Data(contentsOf: documentsDirectoryUrl, options: [])
//            guard let personArray = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else { return }
//            let data2 = try JSONSerialization.data(withJSONObject: personArray, options: [])
//            try data2.write(to: fileUrl, options: [])
//            print(fileUrl)
//        }catch {
//            print(error)
//        }
//
//    }
    
}

extension CategoryListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainCategoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.delegate = self
        cell.lblTitle.text = mainCategoryData[indexPath.row].slug?.replacingOccurrences(of: "-", with: " ").capitalized
        cell.categoryData = mainCategoryData[indexPath.row]
        cell.dataReload(categoryData: mainCategoryData[indexPath.row])
        cell.reloadCell()
        cell.selectedBackgroundView()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryDetailsVC") as! CategoryDetailsVC
        newVC.categoryData = mainCategoryData[indexPath.row]
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = 45
        let mainCategoryData1 = mainData.filter({($0.parentID) == mainCategoryData[indexPath.row].categoryId}).sorted(by: {($0.slug ?? "") < ($1.slug ?? "")})
        for i in mainCategoryData1 {
            height += 45
            let mainCategoryData2 = mainData.filter({($0.parentID) == i.categoryId}).sorted(by: {($0.slug ?? "") < ($1.slug ??  "")})
            height += (mainCategoryData2.count*45)
        }
        return CGFloat(height)
    }
}

extension CategoryListVC: CategoryCellDelegate {
    func categoryCell(_ tableViewCell: CategoryCell, didSelectRowAt indexPath: IndexPath, categoryData: CategoryData) {
        self.view.endEditing(true)
        let newVC = self.storyboard?.instantiateViewController(withIdentifier: "CategoryDetailsVC") as! CategoryDetailsVC
        newVC.categoryData = categoryData
        self.navigationController?.pushViewController(newVC, animated: true)
    }
}

extension CategoryListVC: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        if text.count != 0 {
            self.mainCategoryData = mainData.filter({($0.slug?.replacingOccurrences(of: "-", with: " "))?.localizedStandardContains(text) == true})
            self.tableView.reloadData()
        }else{
            setupData()
        }
    }
}

extension CategoryListVC: AddCategoryDelgate {
    func saveButton(_ viewController: AddCategoryVC, didSave button: UIButton) {
        print("save")
        mainData.removeAll()
        mainData = DemoAppDB.instance.getDemoAppTable()
        setupData()
    }
    
    func cancelButton(_ viewController: AddCategoryVC, didCancel button: UIButton) {
        print("cancel")
    }
}

func json(from object: NSArray) -> String? {
    guard let data = try? JSONSerialization.data(withJSONObject: object) else {
        return nil
    }

    return String(data: data, encoding: String.Encoding.utf8)
}
