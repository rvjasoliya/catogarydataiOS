//
//  ImageCell.swift
//  DemoApp
//
//  Created by iMac on 03/06/22.
//

import UIKit

protocol ImageCellDelegate {
    func removeButton(_ sender: UIButton)
}

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removeBtn: UIButton!
    
    var delegate: ImageCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageView.layer.cornerRadius = 15
        removeBtn.layer.cornerRadius = removeBtn.frame.height/2
        
    }
    
    @IBAction func removeButtonAction(_ sender: UIButton) {
        self.delegate?.removeButton(sender)
    }
}
