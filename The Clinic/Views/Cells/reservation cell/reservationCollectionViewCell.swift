//
//  reservationCollectionViewCell.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/28/21.
//

import UIKit

class reservationCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var reserve_label: UILabel!
    @IBOutlet weak var reserve_view: UIView!
    @IBOutlet weak var date_label: UILabel!
    @IBOutlet weak var from_label: UILabel!
    @IBOutlet weak var to_label: UILabel!
    var formatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(reservationModel : Reservation) {
        formatter.dateFormat = "yyy-MM-dd"
        let currentDate = Date()
        let currentDateString = formatter.string(from: currentDate)
        if currentDateString == reservationModel.date {
            date_label.text = "Today"
        } else {
            date_label.text = reservationModel.date
        }
        from_label.text = "From \(reservationModel.from)"
        to_label.text = "To \(reservationModel.to)"
    }

}
