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
        public let moveWebPage = PublishRelay<URL>()
    }
    
    public lazy var input: InputType = Input()
    public lazy var output: OutputType = Output()
    
    private let bag = DisposeBag()
    public private(set) var searchListPresentModel: SearchListPresentModel
    
    required init(model: SearchListPresentModel) {
        searchListPresentModel = model
        
        rxBind()
    }
    
    private func rxBind() {
        
        input.linkBtnTapped
            .filter { [weak self] (_) -> Bool in
                guard let self = self else { return false }
                return self.searchListPresentModel.urlString.isNotEmpty()
        }.subscribe(onNext: { [weak self] (_) in
            guard let self = self else { return }
            guard let url = URL(string: self.searchListPresentModel.urlString) else { return }
            self.saveURL(urlString: url.absoluteString)
            self.output.moveWebPage.accept((url))
            }).disposed(by: bag)
        
    }
    
    private func saveURL(urlString: String) {
        var linkUrls = UserDefaultManager.clicUrls ?? []
        guard (linkUrls.filter { $0 == urlString }).count == 0 else { return }
        
        linkUrls.append(urlString)
        UserDefaultManager.clicUrls = linkUrls
    }
    
}
