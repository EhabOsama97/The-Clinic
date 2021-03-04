//
//  DoctorTableViewCell.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/26/21.
//

import UIKit
import SDWebImage

class DoctorTableViewCell: UITableViewCell {

    @IBOutlet weak var background_view: UIView!
    @IBOutlet weak var image_view: UIImageView!
    @IBOutlet weak var name_label: UILabel!
    @IBOutlet weak var number_label: UILabel!
    
    @IBOutlet weak var fees_label: UILabel!
    @IBOutlet weak var waiting_label: UILabel!
    @IBOutlet weak var address_label: UILabel!
    @IBOutlet weak var rating_label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(model:Doctor) {
    
        let email = model.email
        let filename = "\(email.SafeDB())_profile_picture.png"
        print("filename : \(filename)")
        StorageManager.shared.downloadImage(refrence: filename) { (result) in
            switch result {
            case .success(let url) :
                print("profile image downloaded successufuulyy")
                self.image_view.sd_setImage(with: url, completed: nil)
                return
            case .failure(let error) :
                print("error in downloading profile image \(error)")
                return
            }
        }
        name_label.text = "Dr \(model.firstName) \(model.lastName)"
        fees_label.text = "\(model.fees) EGP"
        number_label.text = model.mobile
        waiting_label.text = model.waiting
        rating_label.text = model.rating
        address_label.text = model.address
        //adjustView
        background_view.layer.cornerRadius = 30
        background_view.clipsToBounds = true
        //adjust imageview
        image_view.layer.masksToBounds = false
        image_view.layer.cornerRadius = image_view.bounds.height / 2.0
        image_view.clipsToBounds = true
        image_view.layer.borderColor = UIColor(named: "clinic")?.cgColor
        image_view.layer.borderWidth = 2
        image_view.contentMode = .scaleAspectFill
    }
}
