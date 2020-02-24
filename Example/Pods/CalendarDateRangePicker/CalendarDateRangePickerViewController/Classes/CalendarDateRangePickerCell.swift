//
//  CalendarDateRangePickerCell.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

class CalendarDateRangePickerCell: UICollectionViewCell {
    
    enum SelectionType {
        case single, begining, end
    }
    
    private enum Consts {
        static let padding: CGFloat = 5
    }
    
    private let defaultTextColor = UIColor.darkGray
    var highlightedColor: UIColor!
    var font = UIFont(name: "HelveticaNeue", size: CalendarDateRangePickerViewController.defaultCellFontSize) {
        didSet {
            label?.font = font
        }
    }
    
    @objc var selectedColor: UIColor!
    @objc var selectedLabelColor: UIColor!
    @objc var highlightedLabelColor: UIColor!
    var disabledBackgroundColor: UIColor!
    var disabledLabelColor: UIColor!
    @objc var disabledDates: [Date]!
    @objc var disabledTimestampDates: [Int]?
    @objc var date: Date?
    @objc var selectedView: UIImageView?
    @objc var halfBackgroundView: UIView?
    @objc var roundHighlightView: UIView?
    var cellBackgroundView: UIView!
    var leftSelectionImage: UIImage?
    var rightSelectionImage: UIImage?
    
    @objc private var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setup()
    }
    
    @objc func setup() {
        cellBackgroundView = UIView()
        cellBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cellBackgroundView)
        cellBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: Consts.padding).isActive = true
        cellBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Consts.padding).isActive = true
        cellBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Consts.padding).isActive = true
        cellBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Consts.padding).isActive = true
        cellBackgroundView.layer.cornerRadius = 6
        
        label = UILabel(frame: frame)
        label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        label.font = font
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
    }
    
    @objc func reset() {
        self.backgroundColor = UIColor.clear
        label.textColor = defaultTextColor
        label.backgroundColor = UIColor.clear
        cellBackgroundView.backgroundColor = .white
        cellBackgroundView.isHidden = false
        
        if selectedView != nil {
            selectedView?.removeFromSuperview()
            selectedView = nil
        }
        if halfBackgroundView != nil {
            halfBackgroundView?.removeFromSuperview()
            halfBackgroundView = nil
        }
        if roundHighlightView != nil {
            roundHighlightView?.removeFromSuperview()
            roundHighlightView = nil
        }
    }
    
    func select(with selectionType: SelectionType) {
        let width = self.frame.size.width - 6
        let height = self.frame.size.height - Consts.padding * 2 + 4
        selectedView = UIImageView(frame: CGRect(x: Consts.padding, y: Consts.padding - 2, width: width, height: height))
        selectedView?.backgroundColor = selectedColor
        selectedView?.layer.cornerRadius = 6
        self.addSubview(selectedView!)
        self.sendSubviewToBack(selectedView!)
        cellBackgroundView.isHidden = true
        
        label.textColor = selectedLabelColor
        switch selectionType {
        case .begining:
            selectedView?.image = leftSelectionImage
        case .end:
            selectedView?.image = rightSelectionImage
            selectedView?.layer.cornerRadius = 6
        case .single:
            selectedView?.image = nil
        }
    }
    
    @objc func highlightRight() {
        // This is used instead of highlight() when we need to highlight cell with a rounded edge on the left
        let width = self.frame.size.width
        let height = self.frame.size.height
        halfBackgroundView = UIView(frame: CGRect(x: width / 2, y: 0, width: width / 2, height: height))
        halfBackgroundView?.backgroundColor = highlightedColor
        self.addSubview(halfBackgroundView!)
        self.sendSubviewToBack(halfBackgroundView!)
        label.textColor = highlightedLabelColor
        addRoundHighlightView()
    }
    
    @objc func highlightLeft() {
        // This is used instead of highlight() when we need to highlight the cell with a rounded edge on the right.
        let width = self.frame.size.width
        let height = self.frame.size.height
        halfBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: width / 2, height: height))
        halfBackgroundView?.backgroundColor = highlightedColor
        self.addSubview(halfBackgroundView!)
        self.sendSubviewToBack(halfBackgroundView!)
        label.textColor = highlightedLabelColor

        addRoundHighlightView()
    }
    
    @objc func addRoundHighlightView() {
        let width = self.frame.size.width
        let height = self.frame.size.height
        roundHighlightView = UIView(frame: CGRect(x: (width - height) / 2, y: 0, width: height, height: height))
        roundHighlightView?.backgroundColor = highlightedColor
        roundHighlightView?.layer.cornerRadius = height / 2
        self.addSubview(roundHighlightView!)
        self.sendSubviewToBack(roundHighlightView!)
    }
    
    @objc func highlight() {
        self.backgroundColor = highlightedColor
        cellBackgroundView.isHidden = true
        label.textColor = highlightedLabelColor
    }
    
    @objc func disable() {
        cellBackgroundView.backgroundColor = disabledBackgroundColor
        label.textColor = disabledLabelColor
        removeShadow()
    }
    
    func setText(_ text: String, dropShadow: Bool) {
        label.text = text
        if dropShadow {
            addShadow()
        }
        else {
            removeShadow()
        }
    }
}

private extension CalendarDateRangePickerCell {
    func addShadow() {
        let bounds = CGRect(x: 0, y: 0, width: frame.width - Consts.padding * 2, height: frame.width - Consts.padding * 2)
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius)
        cellBackgroundView.layer.shadowPath = shadowPath.cgPath
        cellBackgroundView.layer.shadowColor = UIColor(red: 0.165, green: 0.208, blue: 0.239, alpha: 0.06).cgColor
        cellBackgroundView.layer.shadowOpacity = 1
        cellBackgroundView.layer.shadowRadius = 6
        cellBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 4)
    }
    
    func removeShadow() {
        cellBackgroundView.layer.shadowOpacity = 0
    }
}
