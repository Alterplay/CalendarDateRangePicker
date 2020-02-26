//
//  CalendarDateRangePickerCell.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

class CalendarDateRangePickerCell: UICollectionViewCell {
    
    enum Edge {
        case left, right, allVisible
    }
    
    enum SelectionType {
        case single
        case begining(shouldRemoveHighlight: Bool)
        case end(shouldRemoveHighlight: Bool)
    }
    
    private enum Consts {
        static let padding: CGFloat = 5
    }
    
    var defaultTextColor: UIColor! {
        didSet {
            label?.textColor = defaultTextColor
        }
    }
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
    @objc var selectedImageView: UIImageView?
    @objc var roundHighlightView: UIView?
    var cellBackgroundView: UIView!
    var leftSelectionImage: UIImage?
    var rightSelectionImage: UIImage?
    private var highlightedView: UIView!
    
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
        
        var highlightedFrame = frame
        highlightedFrame.origin.x = 0
        highlightedFrame.origin.y = Consts.padding
        highlightedFrame.size.height = frame.height - Consts.padding * 2
        highlightedFrame.size.width = frame.width + 2
        highlightedView = UIView(frame: highlightedFrame)
        addSubview(highlightedView)
        
        label = UILabel(frame: frame)
        label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        label.font = font
        label.textColor = UIColor.darkGray
        label.textAlignment = NSTextAlignment.center
        self.addSubview(label)
    }
    
    @objc func reset() {
        label.textColor = defaultTextColor
        label.backgroundColor = UIColor.clear
        cellBackgroundView.backgroundColor = .white
        cellBackgroundView.isHidden = true
        highlightedView.isHidden = true
        highlightedView.frame.origin.x = 0
        highlightedView.frame.size.width = frame.width + 2
        
        if selectedImageView != nil {
            selectedImageView?.removeFromSuperview()
            selectedImageView = nil
        }
        if roundHighlightView != nil {
            roundHighlightView?.removeFromSuperview()
            roundHighlightView = nil
        }
    }
    
    func select(with selectionType: SelectionType) {
        let y = Consts.padding - 2
        let width = self.frame.size.width - 6
        let height = self.frame.size.height - Consts.padding * 2 + 4
        
        cellBackgroundView.isHidden = true
        
        label.textColor = selectedLabelColor
        
        let additionalInset: CGFloat = 3
        switch selectionType {
        case .begining(let shouldRemoveHighlight):
            let x = Consts.padding
            selectedImageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
            selectedImageView?.image = leftSelectionImage
            self.addSubview(selectedImageView!)
            self.sendSubviewToBack(selectedImageView!)
            if shouldRemoveHighlight {
                highlightedView.isHidden = true
            } else {
                highlight(edgeToRemove: .left, withAdditionalInset: additionalInset)
            }
                
        case .end(let shouldRemoveHighlight):
            let x = -Consts.padding + 6
            selectedImageView = UIImageView(frame: CGRect(x: x, y: y, width: width, height: height))
            selectedImageView?.image = rightSelectionImage
            self.addSubview(selectedImageView!)
            self.sendSubviewToBack(selectedImageView!)
            if shouldRemoveHighlight {
                highlightedView.isHidden = true
            } else {
                highlight(edgeToRemove: .right, withAdditionalInset: additionalInset)
            }
        case .single:
            cellBackgroundView.backgroundColor = selectedColor
            cellBackgroundView.isHidden = false
            addShadow()
        }
    }

    @objc func addRoundHighlightView() {
        roundHighlightView = UIView(frame: highlightedView.frame)
        roundHighlightView?.backgroundColor = highlightedColor
        self.addSubview(roundHighlightView!)
        self.sendSubviewToBack(roundHighlightView!)
        cellBackgroundView.isHidden = true
    }
    
    func highlight(edgeToRemove: Edge, withAdditionalInset additionalInset: CGFloat = 0) {
        cellBackgroundView.isHidden = true
        highlightedView.backgroundColor = highlightedColor
        highlightedView.isHidden = false
        label.textColor = highlightedLabelColor
        switch edgeToRemove {
        case .allVisible:
            highlightedView.frame.origin.x = 0
            highlightedView.frame.size.width = frame.width + 5
        case .left:
            highlightedView.frame.origin.x = Consts.padding + additionalInset
            highlightedView.frame.size.width -= Consts.padding + additionalInset
        case .right:
            highlightedView.frame.size.width = frame.width - Consts.padding - additionalInset
        }
    }
    
    @objc func disable() {
        cellBackgroundView.backgroundColor = disabledBackgroundColor
        label.textColor = disabledLabelColor
        removeShadow()
    }
    
    func setText(_ text: String, dropShadow: Bool) {
        label.text = text
        if dropShadow {
            cellBackgroundView.isHidden = false
            addShadow()
        }
        else {
            cellBackgroundView.isHidden = true
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
