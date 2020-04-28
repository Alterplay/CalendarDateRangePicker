//
//  CalendarDateRangePickerHeaderView.swift
//  CalendarDateRangePickerViewController
//
//  Created by Miraan on 15/10/2017.
//  Copyright © 2017 Miraan. All rights reserved.
//

import UIKit

class CalendarDateRangePickerHeaderView: UICollectionReusableView {

    @objc var label: UILabel!
	@objc var font: UIFont? = .systemFont(ofSize: 15) {
        didSet { label?.font = font }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLabel()
    }

    @objc func initLabel() {
        label = UILabel(frame: frame)
        label.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        label.font = font
        label.textColor = .black
        label.textAlignment = .center
        addSubview(label)
    }

}
