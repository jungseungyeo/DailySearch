//
//  RecentSearchListTableViewCell.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/17.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

extension Reactive where Base: RecentSearchListTableViewCell {
    var recetnCellTapped: Observable<String?> {
        return base.cellTapped.rx.tap
            .map { _ -> String? in
                return self.base.recentTitle.text
        }.asObservable()
    }
}

class RecentSearchListTableViewCell: BaseTableViewCell {
    
    static let registerID = "\(RecentSearchListTableViewCell.self)"
    
    @IBOutlet weak var recentTitle: UILabel!
    @IBOutlet weak var cellTapped: UIButton!
    
    public var bag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    public func bind(_ recentTitle: String?) {
        self.recentTitle.text = recentTitle
    }
    
}
