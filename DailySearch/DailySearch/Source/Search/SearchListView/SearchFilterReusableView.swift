//
//  SearchFilterReusableView.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

extension Reactive where Base: SearchFilterReusableView {
    var genreFilterBtnTapped: Observable<Void> {
        return base.genreFilterBtn.rx.tap.asObservable()
    }
    
    var listFileterBtnTapped: Observable<Void> {
        return base.listFilterBtn.rx.tap.asObservable()
    }
}

class SearchFilterReusableView: BaseCollectionReusableView {
    
    @IBOutlet weak var genreFilterBtn: UIButton!
    @IBOutlet weak var listFilterBtn: UIButton!
    
    static let registerID = "\(SearchFilterReusableView.self)"
    
    public var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        genreFilterBtn.setTitleColor(DailySearchColor.Style.label,
                                     for: .normal)
        listFilterBtn.setTitleColor(DailySearchColor.Style.label,
                                    for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    public func bind(type: SearchType, filterType: SearchListFilter) {
        genreFilterBtn.setTitle("\(type)", for: .normal)
        listFilterBtn.setTitle("\(filterType)", for: .normal)
    }
    
}
