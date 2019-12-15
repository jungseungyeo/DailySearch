//
//  SearchViewModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import RxCocoa
import RxSwift

enum SearchListFilter: Int, CustomStringConvertible, CaseIterable {
    
    case title = 0
    case date
    
    var description: String {
        switch self {
        case .title:
            return "Title"
        case .date:
            return "Datetime"
        }
    }
}

final class SearchViewModel: NSObject, ReactiveViewModelable {
    
    typealias InputType = Input
    typealias OutputType = Output
    
    struct Input {
        public let searchText = PublishRelay<String>()
        
        public let genreFilterBtnTapped = PublishRelay<Void>()
        public let listFilterBtnTapped = PublishRelay<Void>()
        
        public let searchTypeChanged = PublishRelay<SearchType>()
        public let searchListTypeChanged = PublishRelay<SearchListFilter>()
    }
    
    struct Output {
        public let genreFilterChoiceAlertObservable: Observable<Void>
        public let listFilterChoiceAlert = PublishRelay<SearchListFilterAlertViewController>()
    }
    
    public lazy var input: InputType = Input()
    public lazy var output: OutputType = {
        let genreFilterBtnTapped = input.genreFilterBtnTapped
            .map { _ in return }
        
        return Output(genreFilterChoiceAlertObservable: genreFilterBtnTapped)
    }()
    
    public private(set) lazy var searchgenreType: SearchType = .all
    public private(set) lazy var searchListFilterType: SearchListFilter = .title
    
    private let bag = DisposeBag()
    
    override init() {
        super.init()
        
        rxBind()
    }
    
    private func rxBind() {
        
        input.listFilterBtnTapped
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                let searchListFilterAlertViewController = SearchListFilterAlertViewController.intance(viewModel: SearchListAlertViewModel(filterType: self.searchListFilterType))
                self.output.listFilterChoiceAlert.accept(searchListFilterAlertViewController)
            }).disposed(by: bag)
    }
}
