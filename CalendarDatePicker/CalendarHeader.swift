//
//  CalendarHeader.swift
//  CalendarDatePicker
//
//  Created by David Kong on 6/20/16.
//  Copyright © 2016 David Kong. All rights reserved.
//

import UIKit

let weekDaysList = ["S", "M", ]

class CalendarHeader : UICollectionReusableView {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var lblFirst: UILabel!
    @IBOutlet weak var lblSecond: UILabel!
    @IBOutlet weak var lblThird: UILabel!
    @IBOutlet weak var lblFourth: UILabel!
    @IBOutlet weak var lblFifth: UILabel!
    @IBOutlet weak var lblSixth: UILabel!
    @IBOutlet weak var lblSeventh: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblFirst.adjustsFontSizeToFitWidth = true
        lblSecond.adjustsFontSizeToFitWidth = true
        lblThird.adjustsFontSizeToFitWidth = true
        lblFourth.adjustsFontSizeToFitWidth = true
        lblFifth.adjustsFontSizeToFitWidth = true
        lblSixth.adjustsFontSizeToFitWidth = true
        lblSeventh.adjustsFontSizeToFitWidth = true
        
        let weeksDayList = NSCalendar.currentCalendar().veryShortStandaloneWeekdaySymbols
        if NSCalendar.currentCalendar().firstWeekday == 2 {
            lblFirst.text = weeksDayList[1]
            lblSecond.text = weeksDayList[2]
            lblThird.text = weeksDayList[3]
            lblFourth.text = weeksDayList[4]
            lblFifth.text = weeksDayList[5]
            lblSixth.text = weeksDayList[6]
            lblSeventh.text = weeksDayList[0]
        } else {
            lblFirst.text = weeksDayList[0]
            lblSecond.text = weeksDayList[1]
            lblThird.text = weeksDayList[2]
            lblFourth.text = weeksDayList[3]
            lblFifth.text = weeksDayList[4]
            lblSixth.text = weeksDayList[5]
            lblSeventh.text = weeksDayList[6]
        }
    }
    
}
