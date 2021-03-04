//
//  RatingTableViewCell.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/27/21.
//

import UIKit

class RatingTableViewCell: UITableViewCell {

    @IBOutlet weak var username_label: UILabel!
    @IBOutlet weak var text_label: UILabel!
    @IBOutlet weak var rate_label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(rateModel : Rate) {
        username_label.text = rateModel.userName
        text_label.text = rateModel.text
        
        let attachment = NSTextAttachment()
        attachment.image = UIImage(systemName: "star.fill")
        let attachmentString = NSAttributedString(attachment: attachment)
        let string = NSMutableAttributedString(string: rateModel.rateNum + " ", attributes: [:])
        string.append(attachmentString)
        rate_label.attributedText = string
    }
    
}
