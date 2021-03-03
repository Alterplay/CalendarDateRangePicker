//
//  ViewController.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Improved and maintaining by Ljuka
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import AltyCalendarDateRangePicker

class ViewController: UIViewController {

    private let calendarViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
    
    @IBOutlet weak var label: UILabel!

    @IBAction func didTapButton(_ sender: Any) {
        calendarViewController.delegate = self
        calendarViewController.minimumDate = Date()
        calendarViewController.maximumDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())!
        calendarViewController.selectedStartDate = Date()
        calendarViewController.disabledCellColor = UIColor(red: 0.599, green: 0.627, blue: 0.636, alpha: 0.1)
        calendarViewController.disabledTextColor = UIColor(red: 0.617, green: 0.67, blue: 0.708, alpha: 1)
        calendarViewController.cellHighlightedColor = UIColor(red: 0.173, green: 0.694, blue: 0.384, alpha: 0.5)
        calendarViewController.leftSelectionImage = UIImage(named: "start")
        calendarViewController.rightSelectionImage = UIImage(named: "end")
/*
         Set disabled dates if you want. It's optional...

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        dateRangePickerViewController.disabledDates = [dateFormatter.date(from: "2018-11-13"), dateFormatter.date(from: "2018-11-21")] as? [Date]
         */
        calendarViewController.selectedEndDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())
        calendarViewController.selectedColor = .systemBlue
        calendarViewController.selectedLabelColor = .white
        calendarViewController.titleText = "Select Date Range"
        
        calendarViewController.weekdayCellColor = .black
        calendarViewController.weekdayCellTextColor = .red
        calendarViewController.weekdayHeaderFormat = .long
        calendarViewController.weekdayHeaderStyle = .floating
        
        calendarViewController.selectionMode = .single
        
        let navigationController = UINavigationController(rootViewController: calendarViewController)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }

}

extension ViewController: CalendarDateRangePickerViewControllerDelegate {

    func didCancelPickingDateRange() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    func didPickDateRange(startDate: Date, endDate: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        label.text = dateFormatter.string(from: startDate) + " to " + dateFormatter.string(from: endDate)
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    @objc func didSelectStartDate(startDate: Date){
//        Do something when start date is selected...
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        print(dateFormatter.string(from: startDate))
        
        calendarViewController.highlightedDates = [Calendar.current.date(byAdding: .weekOfMonth, value: 1, to: startDate)!]

    }

    @objc func didSelectEndDate(endDate: Date){
//        Do something when end date is selected...
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        print(dateFormatter.string(from: endDate))
    }
}
