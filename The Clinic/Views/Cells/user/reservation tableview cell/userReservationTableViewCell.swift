//
//  userReservationTableViewCell.swift
//  The Clinic
//
//  Created by Ehab Osama on 3/1/21.
//

import UIKit

protocol userReservationCellDelegate {
    func cancelBtnPressed(reservModel:Reservation,index:Int)
}

class userReservationTableViewCell: UITableViewCell {

    @IBOutlet weak var date_view: UIView!
    @IBOutlet weak var background_view: UIView!
    @IBOutlet weak var doctor_image_view: UIImageView!
    @IBOutlet weak var to_label: UILabel!
    @IBOutlet weak var from_label: UILabel!
    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var doctorName_label: UILabel!
    var delegate:userReservationCellDelegate?
    var indexx:Int?
    var reservModel : Reservation?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        adjustImageViewAndBackgroundView()
    }

    func adjustImageViewAndBackgroundView () {
        
        //adjustView
        background_view.layer.cornerRadius = 30
        background_view.clipsToBounds = true
        //adjust imageview
        doctor_image_view.layer.masksToBounds = false
        doctor_image_view.layer.cornerRadius = doctor_image_view.bounds.height / 2.0
        doctor_image_view.clipsToBounds = true
        doctor_image_view.layer.borderColor = UIColor(named: "clinic")?.cgColor
        doctor_image_view.layer.borderWidth = 2
        doctor_image_view.contentMode = .scaleAspectFill
        
        }
    
    func configure(rservationModel : Reservation) {
        self.reservModel = rservationModel
        date_label.text = rservationModel.date
        from_label.text = rservationModel.from
        to_label.text = rservationModel.to
        doctorName_label.text = rservationModel.doctorName
        let doctorEmail = rservationModel.doctorEmail.SafeDB()
        let doctorProfile = "\(doctorEmail)_profile_picture.png"
        StorageManager.shared.downloadImage(refrence: doctorProfile) { (result) in
            switch result {
            case .success(let url) :
                DispatchQueue.main.async {
                    self.doctor_image_view.sd_setImage(with: url, completed: nil)
                }
                return
            case .failure(_) :
                print("cant download cell's profile picture")
                return
            }
        }
    }
    
    @IBAction func cancel_btn_pressed(_ sender: UIButton) {
        delegate?.cancelBtnPressed(reservModel: self.reservModel!, index: self.indexx!)
    }
    
}
