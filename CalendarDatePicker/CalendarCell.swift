//
//  CalendarCell.swift
//  CalendarDatePicker
//
//  Created by David Kong on 6/17/16.
//  Copyright © 2016 David Kong. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    
    var currentDate: NSDate!
    var isCellSelectable: Bool?
    
    @IBOutlet weak var dayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dayLabel.adjustsFontSizeToFitWidth = true
        self.selectedBackgroundView = UIView.init(frame: self.bounds)
        self.selectedBackgroundView!.layer.backgroundColor = self.tintColor.CGColor
        self.selectedBackgroundView!.layer.masksToBounds = true
    }
    
    func selectedForLabelColor() {
        self.dayLabel.textColor = UIColor.whiteColor()
    }
    
    func deSelectedForLabelColor() {
        let calendar = NSCalendar.currentCalendar()
        if calendar.startOfDayForDate(self.currentDate) == calendar.startOfDayForDate(NSDate()) {
            self.dayLabel.textColor = self.tintColor
        }
        else {
            self.dayLabel.textColor = UIColor.blackColor()
        }
    }
}

