//
//  SwitchCell.swift
//  Yelp
//
//  Created by Unum Sarfraz on 10/20/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SwitchCellDelegate{
     @objc optional func switchCell(switchCell: SwitchCell, didChangeValue value: Bool)
}

class SwitchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var onSwitch: UISwitch!
    
    weak var delegate: SwitchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 3
        
        onSwitch.onTintColor = yelpRed
        onSwitch.thumbTintColor = UIColor.lightGray

        onSwitch.addTarget(self, action: #selector(switchValueChanged), for: UIControlEvents.valueChanged)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func switchValueChanged() {
        delegate?.switchCell?(switchCell: self, didChangeValue: onSwitch.isOn)
        
    }

}
