//
//  CalendarDateRangePickerHeaderView.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

class CalendarDateRangePickerHeaderView: UICollectionReusableView {
    
    @objc var monthLabel: UILabel!
    @objc var yearLabel: UILabel!
    @objc var monthFont = UIFont(name: "HelveticaNeue-Light", size: CalendarDateRangePickerViewController.defaultHeaderFontSize) {
        didSet {
            monthLabel?.font = monthFont
        }
    }
    var yearFont = UIFont(name: "HelveticaNeue-Light", size: CalendarDateRangePickerViewController.defaultHeaderFontSize) {
        didSet {
            yearLabel?.font = yearFont
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView(frame: frame)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        monthLabel = buildLabel(withFont: monthFont)
        stack.addArrangedSubview(monthLabel)
        yearLabel = buildLabel(withFont: yearFont)
        stack.addArrangedSubview(yearLabel)
        addSubview(stack)
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    private func buildLabel(withFont font: UIFont?) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = font
        label.textColor = UIColor.darkGray
        return label
    }
}

