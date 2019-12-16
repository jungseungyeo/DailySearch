//
//  SearchListFilterAlertTableViewCell.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/15.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

class SearchListFilterAlertTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var choiceBoxView: UIView!
    @IBOutlet weak var filterTitle: UILabel!
    
    
    static let registerID = "\(SearchListFilterAlertTableViewCell.self)"
    
    private struct Const {
        let choicBoxViewRadius: CGFloat = 15
        let choicBoxBoardWidht: CGFloat = 0.1
    }
    
    private let const = Const()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        choiceBoxView.clipsToBounds = true
        choiceBoxView.layer.cornerRadius = const.choicBoxViewRadius
        choiceBoxView.layer.borderColor = DailySearchColor.Style.label.cgColor
        choiceBoxView.layer.borderWidth = const.choicBoxBoardWidht
    }
    
    public func bind(isSelected: Bool, filterText: String?) {
        choiceBoxView.backgroundColor = isSelected ? DailySearchColor.Style.label : DailySearchColor.Style.background
        filterTitle.text = filterText
    }
}
