//
//  SubCategoryCell.swift
//  DemoApp
//
//  Created by iMac on 03/06/22.
//

import UIKit

class SubCategoryCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.register(UINib(nibName: "ParentCategoryCell", bundle: nil), forCellReuseIdentifier: "ParentCategoryCell")
        }
    }
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTableView: UIView!
    
    
    var categoryData: CategoryData?
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
        self.tableViewHeight.constant = CGFloat(mainCategoryData.count*45)
    }
}

extension SubCategoryCell: UITableViewDelegate, UITableViewDataSource {    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainCategoryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParentCategoryCell", for: indexPath) as! ParentCategoryCell
        cell.lblTitle.text = mainCategoryData[indexPath.row].slug?.replacingOccurrences(of: "-", with: " ").capitalized
        cell.selectedBackgroundView()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let categoryId = mainCategoryData[indexPath.row].categoryId
        let data = mainData.filter({($0.parentID) == categoryId})
        for i in data {
            print(i.slug ?? "")
        }
    }
}

