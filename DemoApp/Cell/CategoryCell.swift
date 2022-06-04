//
//  CategoryCell.swift
//  DemoApp
//
//  Created by iMac on 02/06/22.
//

import UIKit

protocol CategoryCellDelegate {
    func categoryCell(_ tableViewCell: CategoryCell, didSelectRowAt indexPath: IndexPath, categoryData: CategoryData)
}

class CategoryCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.register(UINib(nibName: "SubCategoryCell", bundle: nil), forCellReuseIdentifier: "SubCategoryCell")
        }
    }
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: UIView!
    
    
    var categoryData: CategoryData?
    var delegate: CategoryCellDelegate?
    var mainCategoryData: [CategoryData] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func dataReload(categoryData: CategoryData){
        let categoryId = categoryData.categoryId
        self.mainCategoryData = mainData.filter({($0.parentID) == categoryId}).sorted(by: {($0.slug ?? "") < ($1.slug ?? "")})
        self.mainTableView.isHidden = self.mainCategoryData.count == 0
        if self.mainCategoryData.count != 0 {
            self.tableView.reloadData()
        }
    }
    
    func reloadCell() {        
        var height = 0
        for i in mainCategoryData {
            height += 45
            let mainCategoryData2 = mainData.filter({($0.parentID) == i.categoryId}).sorted(by: {($0.slug ?? "") < ($1.slug ??  "")})
            height += (mainCategoryData2.count*45)
        }
        self.tableViewHeight.constant = CGFloat(height)
    }
}

extension CategoryCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainCategoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubCategoryCell", for: indexPath) as! SubCategoryCell
        cell.lblTitle.text = mainCategoryData[indexPath.row].slug?.replacingOccurrences(of: "-", with: " ").capitalized
        cell.categoryData = mainCategoryData[indexPath.row]
        cell.dataReload(categoryData: mainCategoryData[indexPath.row])
        cell.reloadCell()
        cell.selectedBackgroundView()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.categoryCell(self, didSelectRowAt: indexPath, categoryData: mainCategoryData[indexPath.row])
    }
}
