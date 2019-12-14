//
//  SearchViewModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import RxCocoa
import RxSwift

enum SearchListFilter: String, CustomStringConvertible {
    case title = "Title"
    case date = "Datetime"
    
    var description: String {
        return self.rawValue
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
    }
    
    public lazy var input: InputType = Input()
    public lazy var output: OutputType = {
        let genreFilterBtnTapped = input.genreFilterBtnTapped
            .map { _ in return }
        
        return Output(genreFilterChoiceAlertObservable: genreFilterBtnTapped)
    }()
    
    public private(set) var searchgenreType: SearchType = .all
    public private(set) var searchListFilterType: SearchListFilter = .title
    
    private let bag = DisposeBag()
    
    override init() {
        super.init()
        
        rxBind()
    }
    
    private func rxBind() {

    }
}
