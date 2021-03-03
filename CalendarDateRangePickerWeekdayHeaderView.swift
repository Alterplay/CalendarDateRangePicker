//
//  CalendarDateRangePickerWeekdayHeaderView.swift
//  AltyCalendarDateRangePicker
//
//  Created by Yurii Lysytsia on 03.03.2021.
//

import UIKit

final class CalendarDateRangePickerWeekdayHeaderView: UIView {
    
    // MARK: - Public properties
    
    var titlesColor = UIColor.darkGray {
        didSet {
            labels.forEach { (label) in
                label.textColor = titlesColor
            }
        }
    }
    
    // MARK: - Private properties
    
    private var labels: [UILabel] {
        return labelsStackView.arrangedSubviews.compactMap({ $0 as? UILabel })
    }
    
    // MARK: - Outlet properties
    
    private let labelsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        labelsStackView.layoutMargins = layoutMargins
    }
    
    // MARK: - Functions
    
    func setTitles(_ titles: [String]) {
        // Remove all subviews
        labelsStackView.arrangedSubviews.forEach { (arrangedSubview) in
            arrangedSubview.removeFromSuperview()
        }
        
        // Add new subviews
        titles.forEach { (title) in
            let label = createLabel(text: title)
            labelsStackView.addArrangedSubview(label)
        }
    }
    
}

// MARK: - Private

private extension CalendarDateRangePickerWeekdayHeaderView {
    
    func setupViews() {
        // Setup view
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.white
        addSubview(labelsStackView)
        
        // Setup labels stack view
        NSLayoutConstraint.activate([
            labelsStackView.topAnchor.constraint(equalTo: topAnchor),
            labelsStackView.leftAnchor.constraint(equalTo: leftAnchor),
            labelsStackView.rightAnchor.constraint(equalTo: rightAnchor),
            labelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
 
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = titlesColor
        label.textAlignment = NSTextAlignment.center
        label.text = text
        return label
    }
    
}
