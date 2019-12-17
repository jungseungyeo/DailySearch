//
//  SearchDetailViewModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/16.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import RxSwift
import RxCocoa

class SearchDetailViewModel: ReactiveViewModelable {
    typealias InputType = Input
    typealias OutputType = Output
    
    struct Input {
        public let linkBtnTapped = PublishRelay<Void>()
    }
    
    struct Output {
        
    }
    
    public lazy var input: InputType = Input()
    public lazy var output: OutputType = Output()
    
    public private(set) var searchListPresentModel: SearchListPresentModel
    
    required init(model: SearchListPresentModel) {
        searchListPresentModel = model
    }
    
}
