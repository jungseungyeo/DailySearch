//
//  BaseCollectionViewCell.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell, BaseViewable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
        setupUI()
    }
    
    func setup() {
        backgroundColor = DailySearchColor.Style.background
    }
    func setupUI() { }
}
