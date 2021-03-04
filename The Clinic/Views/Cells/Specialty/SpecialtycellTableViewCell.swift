//
//  SpecialtycellTableViewCell.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//

import UIKit

class SpecialtycellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var radio_btn_imageView: UIImageView!
    @IBOutlet weak var backGround_view: UIView!
    @IBOutlet weak var Name_label: UILabel!
    @IBOutlet weak var image_view: UIImageView!
    var choosen:Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       
    }

    func Configure(model:specialty) {
        self.choosen = model.choosen
        Name_label.text = model.name
        image_view.image = model.image
        adjustImageView()
        if model.choosen {
            self.radio_btn_imageView.image = UIImage(named: "radioBtnYes")
        } else {
            self.radio_btn_imageView.image = UIImage(named: "sama3a")
        }
    }
    
    private func adjustImageView() {
        //image_view.layer.borderWidth = 3
        image_view.layer.masksToBounds = false
        //image_view.backgroundColor = UIColor(named: "clinic")
        //image_view.layer.borderColor = (UIColor(named: "clinic"))?.cgColor
        //image_view.layer.cornerRadius = 20
        image_view.clipsToBounds = true
        //adjustView
        backGround_view.layer.cornerRadius = 30
        backGround_view.clipsToBounds = true

    }
}
