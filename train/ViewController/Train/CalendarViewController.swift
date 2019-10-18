//
//  CalendarViewController.swift
//  train
//
//  Created by Ghost on 2018/9/19.
//  Copyright © 2018 Ghost. All rights reserved.
//

import UIKit
import CVCalendar

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var menuView: CVCalendarMenuView!
    @IBOutlet weak var calendarView: CVCalendarView!
    
    private var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLayoutSubviews()
        
        menuView.commitMenuViewUpdate()
        calendarView.commitCalendarViewUpdate()
        
        // Menu delegate [Required]
        self.menuView.menuViewDelegate = self
        // Calendar delegate [Required]
        self.calendarView.calendarDelegate = self
        //Display current year and month on navigation bar
        self.title = CVDate(date: Date(), calendar: Calendar.autoupdatingCurrent).globalDescription
        
        //Toggle to today
        self.calendarView.toggleViewWithDate(self.selectedDate)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Commit frames' updates
        self.menuView.commitMenuViewUpdate()
        self.calendarView.commitCalendarViewUpdate()
    }
    
    @IBAction func dismissView(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmSelection(_ sender: UIBarButtonItem) {
        if (Date() > selectedDate) {
            let msgAlertCtr = UIAlertController.init(title: "Heads up", message: "You selected a past date", preferredStyle: .alert)
            
            msgAlertCtr.addAction(UIAlertAction.init(title: "Confirm", style:.default) { (action) -> () in })
            self.present(msgAlertCtr, animated: true, completion: nil)
        } else {
            let dformatter = DateFormatter()
            dformatter.dateFormat = "yyyy-MM-dd"
            TripStationData.shared.date = dformatter.string(from: selectedDate)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension CalendarViewController: CVCalendarMenuViewDelegate, CVCalendarViewDelegate {
    //Settings
    
    //Using month view
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    //Set the first weekday
    func firstWeekday() -> Weekday {
        return .sunday
    }
    
    //Update current display year and month
    func presentedDateUpdated(_ date: CVDate) {
        self.title = date.globalDescription
    }
    
    //divide every line in month display
    func topMarker(shouldDisplayOnDayView dayView: CVCalendarDayView) -> Bool {
        return true
    }
    
    //Auto select the first day when switch to next or previous month
    func shouldAutoSelectDayOnMonthChange() -> Bool {
        return false
    }
    
    //Auto select the first day when switch to next or previous week
    func shouldAutoSelectDayOnWeekChange() -> Bool {
        return false
    }
    
    //Display non-current month's date
    func shouldShowWeekdaysOut() -> Bool {
        return true
    }
    
    //Response when selected
    func didSelectDayView(_ dayView: CVCalendarDayView, animationDidFinish: Bool) {
        selectedDate = dayView.date.convertedDate()!
    }
}
