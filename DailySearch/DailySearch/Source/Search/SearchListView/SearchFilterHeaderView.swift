//
//  SearchHeaderView.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/15.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: SearchFilterHeaderView {
    var genreFilterBtnTapped: Observable<Void> {
        return base.genreFilterBtn.rx.tap.asObservable()
    }
    
    var listFileterBtnTapped: Observable<Void> {
        return base.listFilterBtn.rx.tap.asObservable()
    }
}

class SearchFilterHeaderView: BaseView {
    
    @IBOutlet weak var genreFilterBtn: UIButton!
    @IBOutlet weak var listFilterBtn: UIButton!
    
    @IBOutlet weak var divisionLineView: UIView!
    
    public var bag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        divisionLineView.backgroundColor = DailySearchColor.Style.label
        genreFilterBtn.setTitleColor(DailySearchColor.Style.label, for: .normal)
        listFilterBtn.setTitleColor(DailySearchColor.Style.label, for: .normal)
    }
    
    public func bind(type: SearchType, filterType: SearchListFilter) {
        genreFilterBtn.setTitle("\(type)", for: .normal)
        listFilterBtn.setTitle("\(filterType)", for: .normal)
    }
    
}
