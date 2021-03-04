//
//  userReservationForDoctorTableViewCell.swift
//  The Clinic
//
//  Created by Ehab Osama on 3/1/21.
//

import UIKit

class userReservationForDoctorTableViewCell: UITableViewCell {

    @IBOutlet weak var to_label: UILabel!
    @IBOutlet weak var from_label: UILabel!
    @IBOutlet weak var username_label: UILabel!
    @IBOutlet weak var background_view: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        background_view.layer.cornerRadius = 20
        background_view.clipsToBounds = true
    }

    func configure(reservationModel : Reservation) {
        username_label.text = reservationModel.username
        from_label.text = "From : \(reservationModel.from)"
        to_label.text = "To : \(reservationModel.to)"
        
    }
    
    
}
