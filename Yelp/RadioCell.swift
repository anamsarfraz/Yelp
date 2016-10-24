//
//  RadioCellTableViewCell.swift
//  Yelp
//
//  Created by Unum Sarfraz on 10/22/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol RadioCellDelegate{
    @objc optional func radioCell(radioCell: RadioCell, didTouchInside value: Bool)
}

class RadioCell: UITableViewCell {

    @IBOutlet weak var radioLabel: UILabel!
    @IBOutlet weak var radioButton: UIButton!
    
    weak var delegate: RadioCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 3
        
        radioButton.setImage(UIImage(named: "radioUncheckButton"), for: UIControlState.normal)
        radioButton.setImage(UIImage(named: "radioCheckButton"), for: UIControlState.selected)
        radioButton.addTarget(self, action: #selector(radioButtonValueChanged), for: UIControlEvents.touchUpInside)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func radioButtonValueChanged() {
        delegate?.radioCell?(radioCell: self, didTouchInside: radioButton.isTouchInside)
    }

    
}
