//
//  SpecialtyCollectionViewCell.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//

import UIKit

class SpecialtyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var background_view: UIView!
    
    @IBOutlet weak var image_view: UIImageView!
    
    @IBOutlet weak var name_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func Configure(model:specialty) {
        name_label.text = model.name
        image_view.image = model.image
        adjustImageView()
    }
    
    private func adjustImageView() {
        //image_view.layer.borderWidth = 3
        image_view.layer.masksToBounds = false
        //image_view.backgroundColor = UIColor(named: "clinic")
        //image_view.layer.borderColor = (UIColor(named: "clinic"))?.cgColor
        //image_view.layer.cornerRadius = 20
        image_view.clipsToBounds = true
        //adjustView
        background_view.layer.cornerRadius = 18
        background_view.clipsToBounds = true

    }

}
