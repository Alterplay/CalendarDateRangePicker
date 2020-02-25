//
//  CalendarDateRangePickerViewController.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

public protocol CalendarDateRangePickerViewControllerDelegate: class {
    func didCancelPickingDateRange()
    func didPickDateRange(startDate: Date!, endDate: Date!)
    func didSelectStartDate(startDate: Date!)
    func didSelectEndDate(endDate: Date!)
}

public class CalendarDateRangePickerViewController: UICollectionViewController {
    public enum DayOfWeek {
        case monday
        case sunday
    }
    
    @objc let cellReuseIdentifier = "CalendarDateRangePickerCell"
    @objc let headerReuseIdentifier = "CalendarDateRangePickerHeaderView"
    
    weak public var delegate: CalendarDateRangePickerViewControllerDelegate!
    
    @objc let itemsPerRow = 7
    @objc let collectionViewInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    
    @objc public var minimumDate: Date!
    @objc public var maximumDate: Date!
    
    @objc public var selectedStartDate: Date?
    @objc public var selectedEndDate: Date?
    @objc var selectedStartCell: IndexPath?
    @objc var selectedEndCell: IndexPath?
    
    @objc public var disabledDates: [Date]?
    
    @objc public var cellHighlightedColor = UIColor(white: 0.9, alpha: 1.0)
    @objc public static let defaultCellFontSize:CGFloat = 15.0
    @objc public static let defaultHeaderFontSize:CGFloat = 17.0
    @objc public var cellFont:UIFont = UIFont(name: "HelveticaNeue", size: CalendarDateRangePickerViewController.defaultCellFontSize)!
    @objc public var headerMonthFont: UIFont? = UIFont(name: "HelveticaNeue-Light", size: CalendarDateRangePickerViewController.defaultHeaderFontSize)!
    public var headerYearFont: UIFont? = UIFont(name: "HelveticaNeue-Light", size: CalendarDateRangePickerViewController.defaultHeaderFontSize)!
    public var headerMonthTextColor: UIColor? = .darkGray
    public var headerYearTextColor: UIColor? = .darkGray
    public var leftSelectionImage: UIImage?
    public var rightSelectionImage: UIImage?

    
    @objc public var selectedColor = UIColor(red: 66/255.0, green: 150/255.0, blue: 240/255.0, alpha: 1.0)
    @objc public var selectedLabelColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    @objc public var highlightedLabelColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    public var disabledCellColor = UIColor.gray
    public var disabledTextColor = UIColor.lightGray
    @objc public var titleText = "Select Dates"
    
    public var firstDayOfWeek: DayOfWeek = .monday

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = self.titleText
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.backgroundColor = UIColor.white
        
        collectionView?.register(CalendarDateRangePickerCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        collectionView?.register(CalendarDateRangePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerReuseIdentifier)
        collectionView?.contentInset = collectionViewInsets
        
        if minimumDate == nil {
            minimumDate = Date()
        }
        if maximumDate == nil {
            maximumDate = Calendar.current.date(byAdding: .year, value: 3, to: minimumDate)
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CalendarDateRangePickerViewController.didTapCancel))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(CalendarDateRangePickerViewController.didTapDone))
        self.navigationItem.rightBarButtonItem?.isEnabled = selectedStartDate != nil && selectedEndDate != nil
    }
    
    @objc func didTapCancel() {
        delegate.didCancelPickingDateRange()
    }
    
    @objc func didTapDone() {
        if selectedStartDate == nil || selectedEndDate == nil {
            return
        }
        delegate.didPickDateRange(startDate: selectedStartDate!, endDate: selectedEndDate!)
    }
    
}

extension CalendarDateRangePickerViewController {
    
    // UICollectionViewDataSource
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        let difference = Calendar.current.dateComponents([.month], from: minimumDate, to: maximumDate)
        return difference.month! + 1
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDateForSection = getFirstDateForSection(section: section)
        let weekdayRowItems = 7
        let blankItems = getWeekday(date: firstDateForSection) - 1
        let daysInMonth = getNumberOfDaysInMonth(date: firstDateForSection)
        return weekdayRowItems + blankItems + daysInMonth
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDateRangePickerCell
        
        cell.highlightedColor = self.cellHighlightedColor
        cell.selectedColor = self.selectedColor
        cell.selectedLabelColor = self.selectedLabelColor
        cell.highlightedLabelColor = self.highlightedLabelColor
        cell.disabledBackgroundColor = self.disabledCellColor
        cell.disabledLabelColor = self.disabledTextColor
        cell.font = self.cellFont
        cell.leftSelectionImage = leftSelectionImage
        cell.rightSelectionImage = rightSelectionImage
        cell.reset()
        let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
        if indexPath.item < 7 {
            cell.setText(getWeekdayLabel(weekday: indexPath.item + 1), dropShadow: false)
        } else if indexPath.item < 7 + blankItems {
            cell.setText("", dropShadow: false)
        } else {
            let dayOfMonth = indexPath.item - (7 + blankItems) + 1
            let date = getDate(dayOfMonth: dayOfMonth, section: indexPath.section)
            cell.date = date
            cell.setText("\(dayOfMonth)", dropShadow: true)

            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let datePreFormatted = dateFormatter.string(from: date)
         
            if disabledDates != nil{
                if (disabledDates?.contains(cell.date!))!{
                    cell.disable()
                }
            }
            if isBefore(dateA: date, dateB: minimumDate) {
                cell.disable()
            }
            
            if selectedStartDate != nil && selectedEndDate != nil && isBefore(dateA: selectedStartDate!, dateB: date) && isBefore(dateA: date, dateB: selectedEndDate!) {
                var edge = CalendarDateRangePickerCell.Edge.allVisible
                if indexPath.row % itemsPerRow == 0 {
                    edge = .left
                }
                else if (indexPath.row + 1) % itemsPerRow == 0 {
                    edge = .right
                }
                cell.highlight(edgeToRemove: edge)
            } else if selectedStartDate != nil && areSameDay(dateA: date, dateB: selectedStartDate!) {
                // Cell is selected start date
                let selectionType: CalendarDateRangePickerCell.SelectionType
                if selectedEndDate == nil || areSameDay(dateA: selectedStartDate!, dateB: selectedEndDate!) {
                    selectionType = .single
                } else {
                    selectionType = .begining
                }
                cell.select(with: selectionType)
            } else if selectedEndDate != nil && areSameDay(dateA: date, dateB: selectedEndDate!) {
                cell.select(with: .end)
            }
        }
        return cell
    }
    
    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as! CalendarDateRangePickerHeaderView
            let date = getFirstDateForSection(section: indexPath.section)
            headerView.monthLabel.text = getMonthLabel(date: date)
            headerView.yearLabel.text = getYearLabel(date: date)
            headerView.monthFont = headerMonthFont
            headerView.yearFont = headerYearFont
            headerView.monthLabel.textColor = headerMonthTextColor
            headerView.yearLabel.textColor = headerYearTextColor
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
    
}

extension CalendarDateRangePickerViewController : UICollectionViewDelegateFlowLayout {
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarDateRangePickerCell
        if cell.date == nil {
            return
        }
        if isBefore(dateA: cell.date!, dateB: minimumDate){
            return
        }
        
        if disabledDates != nil{
            if (disabledDates?.contains(cell.date!))!{
                return
            }
        }
        
        if selectedStartDate == nil {
            selectedStartDate = cell.date
            selectedStartCell = indexPath
            delegate.didSelectStartDate(startDate: selectedStartDate)
        } else if selectedEndDate == nil {
            if isBeforeOrSame(dateA: selectedStartDate!, dateB: cell.date!) && !isBetween(selectedStartCell!, and: indexPath) {
                selectedEndDate = cell.date
                delegate.didSelectEndDate(endDate: selectedEndDate)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                // If a cell before the currently selected start date is selected then just set it as the new start date
                selectedStartDate = cell.date
                selectedStartCell = indexPath
                delegate.didSelectStartDate(startDate: selectedStartDate)
            }
        } else {
            selectedStartDate = cell.date
            selectedStartCell = indexPath
            delegate.didSelectStartDate(startDate: selectedStartDate)
            selectedEndDate = nil
        }
        collectionView.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = collectionViewInsets.left + collectionViewInsets.right
        let availableWidth = view.frame.width - padding
        let itemWidth = floor(availableWidth / CGFloat(itemsPerRow))
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.size.width, height: 50)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

extension CalendarDateRangePickerViewController {
    
    // Helper functions
    
    @objc func getFirstDate() -> Date {
        var components = Calendar.current.dateComponents([.month, .year], from: minimumDate)
        components.day = 1
        return Calendar.current.date(from: components)!
    }
    
    @objc func getFirstDateForSection(section: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: section, to: getFirstDate())!
    }
    
    @objc func getMonthLabel(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: date)
    }
    
    func getYearLabel(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: date)
    }
    
    @objc func getWeekdayLabel(weekday: Int) -> String {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.weekday = weekday
        if(firstDayOfWeek == .monday) {
            if weekday == 7 {
                components.weekday = 1
            }
            else {
                components.weekday = weekday + 1
            }
        }
        let date = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: Calendar.MatchingPolicy.strict)
        if date == nil {
            return "E"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEEE"
        return dateFormatter.string(from: date!)
    }
    
    @objc func getWeekday(date: Date) -> Int {
        let weekday = Calendar.current.dateComponents([.weekday], from: date).weekday!
        if(firstDayOfWeek == .monday) {
            if(weekday == 1){
                return 7
            }
            else {
                return weekday - 1
            }
        }
        else {
            return weekday
        }
    }
    
    @objc func getNumberOfDaysInMonth(date: Date) -> Int {
        return Calendar.current.range(of: .day, in: .month, for: date)!.count
    }
    
    @objc func getDate(dayOfMonth: Int, section: Int) -> Date {
        var components = Calendar.current.dateComponents([.month, .year], from: getFirstDateForSection(section: section))
        components.day = dayOfMonth
        return Calendar.current.date(from: components)!
    }
    
    @objc func areSameDay(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedSame
    }
    
    @objc func isBefore(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedAscending
    }
    
    private func isBeforeOrSame(dateA: Date, dateB: Date) -> Bool {
        return isBefore(dateA: dateA, dateB: dateB) || Calendar.current.isDate(dateA, inSameDayAs: dateB)
    }
    
    @objc func isBetween(_ startDateCellIndex: IndexPath, and endDateCellIndex: IndexPath) -> Bool {
        
        if disabledDates == nil{
            return false
        }
        
        var index = startDateCellIndex.row
        var section = startDateCellIndex.section
        var currentIndexPath: IndexPath
        var cell: CalendarDateRangePickerCell?

        while !(index == endDateCellIndex.row && section == endDateCellIndex.section){
            currentIndexPath = IndexPath(row: index, section: section)
            cell = collectionView?.cellForItem(at: currentIndexPath) as? CalendarDateRangePickerCell
            if cell?.date == nil{
                section = section + 1
                let blankItems = getWeekday(date: getFirstDateForSection(section: section)) - 1
                index = 7 + blankItems
                currentIndexPath = IndexPath(row: index, section: section)
                cell = collectionView?.cellForItem(at: currentIndexPath) as? CalendarDateRangePickerCell
            }
            
            if cell != nil && (disabledDates?.contains((cell!.date)!))! {
                return true
            }
            index = index + 1
        }
        
        return false
    }
    
}
