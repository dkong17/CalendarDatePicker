//
//  CalendarView.swift
//  CalendarDatePicker
//
//  Created by David Kong on 6/17/16.
//  Copyright © 2016 David Kong. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let numYears = 2 // Number of years the calendar should display

@objc public protocol CalendarDatePickerDelegate {
    optional    func calendarPicker(_: CalendarDatePickerViewController, didCancel error : NSError)
    optional    func calendarPicker(_: CalendarDatePickerViewController, didSelectDate date : NSDate)
    optional    func calendarPicker(_: CalendarDatePickerViewController, didSelectMultipleDate dates : [NSDate])
}

public class CalendarDatePickerViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var datePicker: UIDatePicker!
    
    //private let bcColor = UIColor.init(colorLiteralRed: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    private let bcColor = UIColor.groupTableViewBackgroundColor()
    
    var dateDisplay : UILabel?
    
    public var calendarDelegate : CalendarDatePickerDelegate?
    public var calendarView : UICollectionView?
    
    public var selectedDate : NSDate
    private var selectedIndex : NSIndexPath?
    
    private var minDateTime : NSDate
    public var calendarStartDate : NSDate = NSDate()
    
    private var cellDimension : CGFloat
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = bcColor
        let screen = UIScreen.mainScreen()
        
        // Display
        dateDisplay = UILabel.init(frame: CGRect(x: 0, y: 0, width: screen.bounds.width, height: 40))
        dateDisplay?.backgroundColor = UIColor.whiteColor()
        dateDisplay?.textAlignment = .Left
        dateDisplay?.textColor = self.view.tintColor
        dateDisplay?.text = minDateTime.timeNameFull()
        self.view.frame.height
        // Calendar setup
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year, .Month, .Hour], fromDate: self.calendarStartDate)
        self.calendarStartDate = NSDate(year: components.year, month: components.month, day: 1)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.headerReferenceSize = CGSizeMake(screen.bounds.width, cellDimension*2)
        calendarView = UICollectionView.init(frame: CGRect.init(x: 0, y: 40, width: screen.bounds.width, height: self.view.frame.height - 84 - self.datePicker!.frame.height), collectionViewLayout: layout)
        self.calendarView!.backgroundColor = UIColor.clearColor()
        self.calendarView!.showsHorizontalScrollIndicator = false
        self.calendarView!.showsVerticalScrollIndicator = false
        self.calendarView!.backgroundColor = UIColor.clearColor()
        self.calendarView!.delegate = self
        self.calendarView!.dataSource = self
        self.calendarView!.allowsMultipleSelection = false
        
        // Register nibs
        self.calendarView!.registerNib(UINib(nibName: "CalendarCell", bundle: NSBundle(forClass: self.dynamicType)), forCellWithReuseIdentifier: reuseIdentifier)
        
        self.calendarView!.registerNib(UINib(nibName: "CalendarHeader", bundle: NSBundle(forClass: self.dynamicType )), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header")
        
        // Date Picker
        self.datePicker.minimumDate = minDateTime
        self.datePicker.setDate(minDateTime, animated: false)
        
        self.view.addSubview(calendarView!)
        self.view.addSubview(dateDisplay!)
    }

    required public init?(coder aDecoder: NSCoder) {
        let screen = UIScreen.mainScreen()
        cellDimension = screen.bounds.width / 7.0
        // Initialize view with TODAY selected
        let components = NSCalendar.currentCalendar().components([.Calendar, .Era, .Year, .Month, .Day, .Hour], fromDate: NSDate())
        components.hour += 1
        self.minDateTime = NSCalendar.currentCalendar().dateFromComponents(components)!
        self.selectedDate = minDateTime
        super.init(coder: aDecoder)
    }
    
    override public func viewWillAppear(animated: Bool) {
        let prefixDays = ( calendarStartDate.weekday() - NSCalendar.currentCalendar().firstWeekday)
        self.selectedIndex = NSIndexPath.init(forItem: prefixDays + minDateTime.day() - 1, inSection: 0)
        self.calendarView!.selectItemAtIndexPath(selectedIndex, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
    }
    
    /** CollectionViewDataSource protocols. */
     
    // Number of sections == number of months
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let numberOfMonths = 12 * numYears
        return numberOfMonths
    }
    
    // Items per section == days per month + prefix + suffix
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let firstDayOfMonth = calendarStartDate.dateByAddingMonths(section)
        let addingPrefixDaysWithMonthDyas = ( firstDayOfMonth.numberOfDaysInMonth() + firstDayOfMonth.weekday() - NSCalendar.currentCalendar().firstWeekday )
        let addingSuffixDays = addingPrefixDaysWithMonthDyas%7
        var totalNumber  = addingPrefixDaysWithMonthDyas
        if addingSuffixDays != 0 {
            totalNumber = totalNumber + (7 - addingSuffixDays)
        }
        
        return totalNumber
    }
    
    // Setting up cells
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CalendarCell
        let firstDayOfThisMonth = calendarStartDate.dateByAddingMonths(indexPath.section)
        let prefixDays = ( firstDayOfThisMonth.weekday() - NSCalendar.currentCalendar().firstWeekday)
        cell.dayLabel.textColor = UIColor.blackColor()
        cell.selectedBackgroundView!.layer.cornerRadius = cellDimension/2.0
        
        if indexPath.row >= prefixDays {
            cell.isCellSelectable = true
            let currentDate = firstDayOfThisMonth.dateByAddingDays(indexPath.row-prefixDays)
            let nextMonthFirstDay = firstDayOfThisMonth.dateByAddingDays(firstDayOfThisMonth.numberOfDaysInMonth()-1)
            
            cell.currentDate = currentDate
            cell.dayLabel.text = "\(currentDate.day())"
            
            // Hide suffix
            if (currentDate > nextMonthFirstDay) {
                cell.isCellSelectable = false
                cell.dayLabel.textColor = UIColor.clearColor()
            }
            // Disable days before TODAY
            if NSCalendar.currentCalendar().startOfDayForDate(cell.currentDate) < NSCalendar.currentCalendar().startOfDayForDate(NSDate()) {
                cell.isCellSelectable = false
                cell.dayLabel.textColor = UIColor.lightGrayColor()
            }
            // Different text color for TODAY
            if currentDate.isToday() {
                cell.dayLabel.textColor = self.view.tintColor
            }
            // Set the selected date background view
            if cell.currentDate.isDateSameDay(selectedDate) {
                cell.selectedForLabelColor()
            }
        }
        // Hide prefix
        else {
            cell.isCellSelectable = false
            cell.dayLabel.textColor = UIColor.clearColor()
        }
        cell.userInteractionEnabled = cell.isCellSelectable!
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(cellDimension, cellDimension)
    }

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    // Add Header
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", forIndexPath: indexPath) as! CalendarHeader
            
            let startDate = self.calendarStartDate
            let firstDayOfMonth = startDate.dateByAddingMonths(indexPath.section)
            
            header.monthLabel.text = firstDayOfMonth.monthNameFull()
            header.backgroundColor = bcColor
            return header;
        }
        
        return UICollectionReusableView()
    }
    
    /** Responding to gestures */
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CalendarCell
        if cell.currentDate.isDateSameDay(selectedDate) { return }
        cell.selectedForLabelColor()
        self.selectedIndex = indexPath
        let monthDifference = cell.currentDate.month() - selectedDate.month()
        let dayDifference = cell.currentDate.day() - selectedDate.day()
        selectedDate = selectedDate.dateByAddingMonths(monthDifference)
        selectedDate = selectedDate.dateByAddingDays(dayDifference)
        if selectedDate.earlierDate(minDateTime).isEqualToDate(selectedDate) {
            selectedDate = minDateTime
        }
        self.datePicker!.date = selectedDate
        self.dateDisplay?.text = selectedDate.timeNameFull()
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? CalendarCell {
            cell.deSelectedForLabelColor()
        }
    }
    
    /** Date Picker action. */
    @IBAction func setTime(sender: AnyObject) {
        if self.datePicker.date.earlierDate(minDateTime).isEqualToDate(self.datePicker.date) {
            self.selectedDate = minDateTime
        }
        else {
            self.selectedDate = self.datePicker.date
        }
        self.dateDisplay!.text = selectedDate.timeNameFull()
    }
    
}
