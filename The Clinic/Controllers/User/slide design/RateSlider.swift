//
//  RateSlider.swift
//  The Clinic
//
//  Created by Ehab Osama on 2/28/21.
//

import UIKit

@IBDesignable
class RateSlider: UISlider {

    @IBInspectable var thumbImage: UIImage? {
        didSet {
            setThumbImage(thumbImage, for: .normal)
        }
    }
    @IBInspectable var thumbHighlightedImage: UIImage? {
        didSet {
            setThumbImage(thumbHighlightedImage, for: .highlighted)
        }
    }

}
