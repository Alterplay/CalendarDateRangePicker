//
//  CalendarDateRangePickerViewController.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Improved and maintaining by Ljuka
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

public protocol CalendarDateRangePickerViewControllerDelegate: class {
    func didCancelPickingDateRange()
    func didPickDateRange(startDate: Date, endDate: Date)
    func didSelectStartDate(startDate: Date)
    func didSelectEndDate(endDate: Date)
}

public extension CalendarDateRangePickerViewControllerDelegate {
    func didCancelPickingDateRange() { }
    func didPickDateRange(startDate: Date, endDate: Date) { }
}

public class CalendarDateRangePickerViewController: UICollectionViewController {
    
    @objc public var selectedStartDate: Date?
    @objc public var selectedEndDate: Date?
    @objc public var selectedStartCell: IndexPath?
    @objc public var selectedEndCell: IndexPath?
    
    @objc public var disabledDates: [Date]?
    public var occupiedDate: Date?
    
    @objc public var cellHighlightedColor = UIColor(white: 0.9, alpha: 1.0)
    @objc public static let defaultCellFontSize: CGFloat = 15.0
    @objc public static let defaultHeaderFontSize: CGFloat = 17.0
    
    @objc public var dayCellFont: UIFont = .systemFont(ofSize: 17)
    @objc public var headerFont: UIFont = .systemFont(ofSize: 15)
    
    public var defaultCalendarCellTextColor = UIColor.darkGray
    public var leftSelectionImage: UIImage?
    public var rightSelectionImage: UIImage?
    
    public var headerTextAlignment: NSTextAlignment = .center
    
    @objc public var selectedColor = UIColor(red: 66/255.0, green: 150/255.0, blue: 240/255.0, alpha: 1.0)
    @objc public var selectedLabelColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    @objc public var highlightedLabelColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
    public var disabledCellColor = UIColor.gray
    public var disabledTextColor = UIColor.lightGray
    public var calendarBackgroundColor = UIColor.white
    @objc public var titleText = "Select Dates"
    
    // MARK: - Public properties
    
    public weak var delegate: CalendarDateRangePickerViewControllerDelegate?
    
    public var minimumDate: Date = Date()
    public var maximumDate: Date = Calendar.current.date(byAdding: .year, value: 3, to: Date())!
    
    public var firstDayOfWeek: DayOfWeek = .monday
    public var selectionMode: SelectionMode = .range
    
    public var highlightedDates = [Date]()
    
    public var weekdayCellColor = UIColor.white {
        didSet {
            weekdayHeaderView.backgroundColor = weekdayCellColor
        }
    }
    
    public var weekdayCellTextColor = UIColor.darkGray {
        didSet {
            weekdayHeaderView.titlesColor = weekdayCellTextColor
        }
    }
    
    public var weekdayHeaderStyle: WeekdayHeaderStyle = .floating {
        didSet {
            updateWeekdayHeaderStyle()
        }
    }
    
    public var weekdayHeaderFormat: WeekdayHeaderFormat = .long {
        didSet {
            updateWeekdayHeaderFormat()
        }
    }
    
    // MARK: - Private properties
    
    private var collectionViewInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16) {
        didSet {
            collectionView.contentInset = collectionViewInsets
        }
    }
    
    private var initialScroll = false
    
    // MARK: - Outlet properties
    
    private let weekdayHeaderView = CalendarDateRangePickerWeekdayHeaderView()
    
    // MARK: - Lifecycle
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    public func reloadAndScrollToMid() {
        collectionView.reloadData()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let calendar = Calendar.current
            let dateScrollTo = self.selectedStartDate ?? Date()
            let yearDiff = calendar.component(.year, from: dateScrollTo) - calendar.component(.year, from: self.minimumDate)
            let selectedMonth = calendar.component(.month, from: dateScrollTo) + (yearDiff * 12) - (calendar.component(.month, from: self.minimumDate))
            let dateIndexPath = IndexPath(row: calendar.component(.day, from: dateScrollTo), section: selectedMonth)
            self.collectionView.scrollToItem(at: dateIndexPath, at: .centeredVertically, animated: false)
        }
    }
    
    @objc func didTapCancel() {
        delegate?.didCancelPickingDateRange()
    }
    
    @objc func didTapDone() {
        if selectedStartDate == nil || selectedEndDate == nil {
            return
        }
        delegate?.didPickDateRange(startDate: selectedStartDate!, endDate: selectedEndDate!)
    }
    
    public func scrollToSelectedRange() {
        if self.selectionMode == .single {
            scroll(to: selectedStartCell)
        } else {
            scroll(to: selectedEndCell)
        }
    }
    
    // MARK: - Helpers
    
    public enum WeekdayHeaderStyle: Int {
        /// Header will placed on the start for each months after month name.
        case floating
        
        /// Header will placed on the top of calendar
        case fixed
    }
    
    public enum WeekdayHeaderFormat: String {
        /// Short format for header titles: [M, T, W, T, F, S, S]
        case short = "EEEEE"
        
        /// Long format for header titles: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
        case long = "E"
    }
    
    public enum DayOfWeek {
        case monday
        case sunday
    }
    
    public enum SelectionMode {
        case single, range
    }
    
}

// MARK: - UICollectionViewDataSource

extension CalendarDateRangePickerViewController {
    
    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSection()
    }
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let firstDateForSection = getFirstDateForSection(section: section)
        let weekdayRowItems = weekdayHeaderStyle == .floating ? Constants.itemsPerRow : 0
        let blankItems = getWeekday(date: firstDateForSection) - 1
        let daysInMonth = getNumberOfDaysInMonth(date: firstDateForSection)
        return weekdayRowItems + blankItems + daysInMonth
    }
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseIdentifier, for: indexPath) as! CalendarDateRangePickerCell
        
        cell.backgroundColor = collectionView.backgroundColor
        cell.highlightedColor = cellHighlightedColor
        cell.selectedColor = selectedColor
        cell.selectedLabelColor = selectedLabelColor
        cell.highlightedLabelColor = highlightedLabelColor
        cell.disabledBackgroundColor = disabledCellColor
        cell.disabledLabelColor = disabledTextColor
        cell.defaultTextColor = defaultCalendarCellTextColor
        cell.font = dayCellFont
        cell.leftSelectionImage = leftSelectionImage
        cell.rightSelectionImage = rightSelectionImage
        cell.reset()
        
        let blankItems = getWeekday(date: getFirstDateForSection(section: indexPath.section)) - 1
        if weekdayHeaderStyle == .floating, indexPath.item < Constants.itemsPerRow {
            // Weekday name item, display only when weekday header syle is `.floating`
            cell.defaultTextColor = weekdayCellTextColor
            cell.setText(getWeekdayLabel(weekday: indexPath.item + 1), dropShadow: false)
        } else if indexPath.item < (weekdayHeaderStyle == .floating ? Constants.itemsPerRow : 0) + blankItems {
            // Empty items on the start of the month
            cell.setText("", dropShadow: false)
        } else {
            // Filled items
            let dayOfMonth = indexPath.item - ((weekdayHeaderStyle == .floating ? Constants.itemsPerRow : 0) + blankItems) + 1
            let date = getDate(dayOfMonth: dayOfMonth, section: indexPath.section)
            cell.date = date
            cell.setText("\(dayOfMonth)", dropShadow: true)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            if let disabledDates = disabledDates, disabledDates.contains(cell.date!) {
                cell.disable()
            }
            
            if highlightedDates.contains(where: { areSameDay(dateA: $0, dateB: date) }) {
                // Cell should be highlighted only
                cell.highlight(edgeToRemove: .allVisibleRounded)
            }
            
            if isBefore(dateA: date, dateB: minimumDate) || isAfter(dateA: date, dateB: maximumDate) {
                cell.disable()
            }
            
            if selectedStartDate != nil && selectedEndDate != nil && isBefore(dateA: selectedStartDate!, dateB: date) && isBefore(dateA: date, dateB: selectedEndDate!) {
                var edge = CalendarDateRangePickerCell.Edge.allVisible
                if isLeftEdge(row: indexPath.row) {
                    edge = .left
                } else if isRightEdge(row: indexPath.row) {
                    edge = .right
                }
                cell.highlight(edgeToRemove: edge)
            } else if selectedStartDate != nil && areSameDay(dateA: date, dateB: selectedStartDate!) {
                // Cell is selected start date
                let selectionType: CalendarDateRangePickerCell.SelectionType
                if selectionMode == .single {
                    selectionType = .single
                } else if selectedEndDate == nil {
                    selectionType = .begining(shouldRemoveHighlight: true)
                } else if areSameDay(dateA: selectedStartDate!, dateB: selectedEndDate!) {
                    selectionType = .single
                } else {
                    selectionType = .begining(shouldRemoveHighlight: isRightEdge(row: indexPath.row))
                }
                cell.select(with: selectionType)
            } else if selectedEndDate != nil && areSameDay(dateA: date, dateB: selectedEndDate!) {
                cell.select(with: .end(shouldRemoveHighlight: isLeftEdge(row: indexPath.row)))
            } else if let occupiedDate = occupiedDate, areSameDay(dateA: date, dateB: occupiedDate) {
                cell.selectedColor = selectedColor.withAlphaComponent(0.4)
                cell.select(with: .single)
            }
            cell.applyCurrentDateBorder(isToday(date: date))
        }
        return cell
    }
    
    override public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.headerReuseIdentifier, for: indexPath) as! CalendarDateRangePickerHeaderView
            headerView.label.text = getMonthLabel(date: getFirstDateForSection(section: indexPath.section))
            headerView.label.textAlignment = headerTextAlignment
            headerView.font = headerFont
            return headerView
        default:
            fatalError("Unexpected element kind")
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CalendarDateRangePickerViewController: UICollectionViewDelegateFlowLayout {
    
    override public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! CalendarDateRangePickerCell
        if cell.date == nil {
            return
        }
        if isBefore(dateA: cell.date!, dateB: minimumDate) || isAfter(dateA: cell.date!, dateB: maximumDate) {
            return
        }
        
        if let disabledDates = disabledDates, disabledDates.contains(cell.date!) {
            return
        }
        
        if selectedStartDate == nil {
            selectStartDate(cell.date, withIndexPath: indexPath)
        } else if selectedEndDate == nil {
            if selectionMode == .single {
                selectStartDate(cell.date, withIndexPath: indexPath)
                collectionView.reloadData()
                return
            }
            if isBeforeOrSame(dateA: selectedStartDate!, dateB: cell.date!) && !isBetween(selectedStartCell!, and: indexPath) {
                selectedEndDate = cell.date
                selectedEndCell = indexPath
                guard let selectedEndDate = selectedEndDate else { return }
                delegate?.didSelectEndDate(endDate: selectedEndDate)
                navigationItem.rightBarButtonItem?.isEnabled = true
            } else {
                // If a cell before the currently selected start date is selected then just set it as the new start date
                selectStartDate(cell.date, withIndexPath: indexPath)
            }
        } else {
            selectStartDate(cell.date, withIndexPath: indexPath)
            selectedEndDate = nil
            selectedEndCell = nil
        }
        collectionView.reloadData()
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = collectionViewInsets.left + collectionViewInsets.right
        let availableWidth = view.frame.width - padding
        let itemWidth = floor(availableWidth / CGFloat(Constants.itemsPerRow))
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
        dateFormatter.dateFormat = "MMMM  yyyy"
        return dateFormatter.string(from: date).capitalized
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
        if firstDayOfWeek == .monday {
            if weekday == Constants.itemsPerRow {
                components.weekday = 1
            } else {
                components.weekday = weekday + 1
            }
        }
        guard let date = Calendar.current.nextDate(after: Date(), matching: components, matchingPolicy: Calendar.MatchingPolicy.strict) else {
            return weekdayHeaderFormat.rawValue
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = weekdayHeaderFormat.rawValue
        return dateFormatter.string(from: date).capitalized
    }
    
    @objc func getWeekday(date: Date) -> Int {
        let weekday = Calendar.current.dateComponents([.weekday], from: date).weekday!
        if firstDayOfWeek == .monday {
            if weekday == 1 {
                return Constants.itemsPerRow
            } else {
                return weekday - 1
            }
        } else {
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
    
    private func isAfter(dateA: Date, dateB: Date) -> Bool {
        return Calendar.current.compare(dateA, to: dateB, toGranularity: .day) == ComparisonResult.orderedDescending
    }
    
    private func isBeforeOrSame(dateA: Date, dateB: Date) -> Bool {
        return isBefore(dateA: dateA, dateB: dateB) || Calendar.current.isDate(dateA, inSameDayAs: dateB)
    }
    
    private func isToday(date: Date) -> Bool {
        return Calendar.current.isDateInToday(date)
    }
    
    @objc func isBetween(_ startDateCellIndex: IndexPath, and endDateCellIndex: IndexPath) -> Bool {
        
        if disabledDates == nil {
            return false
        }
        
        var index = startDateCellIndex.row
        var section = startDateCellIndex.section
        var currentIndexPath: IndexPath
        var cell: CalendarDateRangePickerCell?
        
        while !(index == endDateCellIndex.row && section == endDateCellIndex.section) {
            currentIndexPath = IndexPath(row: index, section: section)
            cell = collectionView?.cellForItem(at: currentIndexPath) as? CalendarDateRangePickerCell
            if cell?.date == nil {
                section += 1
                let blankItems = getWeekday(date: getFirstDateForSection(section: section)) - 1
                index = Constants.itemsPerRow + blankItems
                currentIndexPath = IndexPath(row: index, section: section)
                cell = collectionView?.cellForItem(at: currentIndexPath) as? CalendarDateRangePickerCell
            }
            
            if cell != nil && (disabledDates?.contains((cell!.date)!))! {
                return true
            }
            index += 1
        }
        return false
    }
    
    private func isLeftEdge(row: Int) -> Bool {
        return row % Constants.itemsPerRow == 0
    }
    
    private func isRightEdge(row: Int) -> Bool {
        return (row + 1) % Constants.itemsPerRow == 0
    }
    
    private func selectStartDate(_ startDate: Date?, withIndexPath indexPath: IndexPath) {
        selectedStartDate = startDate
        selectedStartCell = indexPath
        guard let selectedStartDate = selectedStartDate else { return }
        delegate?.didSelectStartDate(startDate: selectedStartDate)
    }
    
    private func scroll(to indexPath: IndexPath?, animated: Bool = true) {
        guard let indexPath = indexPath else { return }
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            if cell.frame.maxY - collectionView.contentOffset.y > collectionView.frame.height - collectionView.contentInset.bottom {
                collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
            }
        } else {
            collectionView.scrollToItem(at: indexPath, at: .bottom, animated: animated)
        }
    }
    
    private func numberOfSection() -> Int {
        guard let minimumDateStartOfMonth = Calendar.current.dateInterval(of: .month, for: minimumDate)?.start else {  return 0 }
        guard let maximumDateEndOfMonth = Calendar.current.dateInterval(of: .month, for: maximumDate)?.end else { return 0 }
        guard let difference = Calendar.current.dateComponents([.month, .day], from: minimumDateStartOfMonth, to: maximumDateEndOfMonth).month else { return 0 }
        return difference
    }
}

// MARK: - Private

private extension CalendarDateRangePickerViewController {
    
    // MARK: - Views
    
    func setupViews() {
        // Prepare collecton view
        collectionView?.backgroundColor = calendarBackgroundColor
        collectionView?.register(CalendarDateRangePickerCell.self, forCellWithReuseIdentifier: Constants.cellReuseIdentifier)
        collectionView?.register(CalendarDateRangePickerHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Constants.headerReuseIdentifier)
        
        // Setup view
        view.addSubview(weekdayHeaderView)
        
        // Setup navigation item
        title = titleText
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(CalendarDateRangePickerViewController.didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(CalendarDateRangePickerViewController.didTapDone))
        navigationItem.rightBarButtonItem?.isEnabled = selectedStartDate != nil && selectedEndDate != nil
        
        // Setup weekday header view
        NSLayoutConstraint.activate([
            weekdayHeaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weekdayHeaderView.leftAnchor.constraint(equalTo: view.leftAnchor),
            weekdayHeaderView.rightAnchor.constraint(equalTo: view.rightAnchor),
            weekdayHeaderView.heightAnchor.constraint(equalToConstant: Constants.fixedWeekdayHeaderHeight)
        ])
        weekdayHeaderView.layoutMargins = UIEdgeInsets(top: 0, left: collectionViewInsets.left, bottom: 0, right: collectionViewInsets.right)
        updateWeekdayHeaderStyle()
        updateWeekdayHeaderFormat()
        
        // Setup collection view
        collectionView?.dataSource = self
        collectionView?.delegate = self
    }
    
    func updateWeekdayHeaderStyle() {
        switch weekdayHeaderStyle {
        case .floating:
            weekdayHeaderView.isHidden = true
            collectionViewInsets.top = 0
        case .fixed:
            weekdayHeaderView.isHidden = false
            collectionViewInsets.top = Constants.fixedWeekdayHeaderHeight
        }
    }
    
    func updateWeekdayHeaderFormat() {
        let weekdayTitles = (1...Constants.itemsPerRow).map { getWeekdayLabel(weekday: $0) }
        weekdayHeaderView.setTitles(weekdayTitles)
    }
    
    // MARK: - Helpers
    
    private enum Constants {
        static let fixedWeekdayHeaderHeight: CGFloat = 40
        static let cellReuseIdentifier = String(describing: CalendarDateRangePickerCell.self)
        static let headerReuseIdentifier = String(describing: CalendarDateRangePickerHeaderView.self)
        static let itemsPerRow = 7
    }
    
}
