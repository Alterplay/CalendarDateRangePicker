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

    @IBOutlet weak var label: UILabel!

    @IBAction func didTapButton(_ sender: Any) {
        let dateRangePickerViewController = CalendarDateRangePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
        dateRangePickerViewController.delegate = self
        dateRangePickerViewController.minimumDate = Date()
        dateRangePickerViewController.maximumDate = Calendar.current.date(byAdding: .year, value: 2, to: Date())!
        dateRangePickerViewController.selectedStartDate = Date()
        dateRangePickerViewController.disabledCellColor = UIColor(red: 0.599, green: 0.627, blue: 0.636, alpha: 0.1)
        dateRangePickerViewController.disabledTextColor = UIColor(red: 0.617, green: 0.67, blue: 0.708, alpha: 1)
        dateRangePickerViewController.cellHighlightedColor = UIColor(red: 0.173, green: 0.694, blue: 0.384, alpha: 0.5)
        dateRangePickerViewController.leftSelectionImage = UIImage(named: "start")
        dateRangePickerViewController.rightSelectionImage = UIImage(named: "end")
/*
         Set disabled dates if you want. It's optional...

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        dateRangePickerViewController.disabledDates = [dateFormatter.date(from: "2018-11-13"), dateFormatter.date(from: "2018-11-21")] as? [Date]
         */
        dateRangePickerViewController.selectedEndDate = Calendar.current.date(byAdding: .day, value: 10, to: Date())
        dateRangePickerViewController.selectedColor = UIColor.clear
        dateRangePickerViewController.selectedLabelColor = .white
        dateRangePickerViewController.titleText = "Select Date Range"
        let navigationController = UINavigationController(rootViewController: dateRangePickerViewController)
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
    }

    @objc func didSelectEndDate(endDate: Date){
//        Do something when end date is selected...
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        print(dateFormatter.string(from: endDate))
    }
}
