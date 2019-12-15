//
//  SearchLIstAlertViewModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/15.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import RxCocoa
import RxSwift

class SearchListAlertViewModel: NSObject, ReactiveViewModelable {
    
    typealias InputType = Input
    typealias OutputType = Output
    
    struct Input {
        public let selectedFilter = PublishRelay<Int>()
    }
    
    struct Output {
        public let reloadTable = PublishRelay<Void>()
    }
    
    public lazy var input: InputType = Input()
    public lazy var output: OutputType = Output()
    
    private let bag = DisposeBag()
    
    public private(set) var currentFilterType: SearchListFilter = .title
    
    convenience init(filterType: SearchListFilter) {
        self.init()
        self.currentFilterType = filterType
        rxBind()
    }
    
    private override init() { super.init() }
    
    private func rxBind() {
        input.selectedFilter
            .subscribe(onNext: { [weak self] (index) in
                guard let self = self else { return }
                guard let filterType = SearchListFilter.init(rawValue: index) else { return }
                self.currentFilterType = filterType
                self.output.reloadTable.accept(())
            }).disposed(by: bag)
    }

}

extension SearchListAlertViewModel {
    public func isSelectedType(to index: Int) -> Bool {
        guard let filterType = SearchListFilter.init(rawValue: index) else {
            return false
        }
        return filterType == currentFilterType
    }
    
    public func filterText(to index: Int) -> String? {
        guard let filterType = SearchListFilter.init(rawValue: index) else {
            return nil
        }
        return "\(filterType)"
    }
}
