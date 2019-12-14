//
//  IntroViewModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import RxCocoa
import RxSwift

enum IntroViewState {
    case requesting
    case complete
    case error(Error?)
}

final class IntroViewModel: NSObject, ReactiveViewModelable {
    
    typealias InputType = Input
    typealias OutputType = Output
    
    struct Input {
        public let request = PublishRelay<Void>()
    }
    
    struct Output {
        public let state = PublishRelay<IntroViewState>()
    }
    
    public lazy var input: InputType = Input()
    public lazy var output: OutputType = Output()
    
    private let bag = DisposeBag()
    
    private struct Const {
        let exposureTimeSecond: Int = 3
    }
    
    private let const = Const()
    
    override init() {
        super.init()
        
        rxBind()
    }
    
    private func rxBind() {
        
        input.request
            .map { _ -> IntroViewState in
                return .requesting
        }.bind(to: output.state)
        .disposed(by: bag)
        
        input.request
            .delay(.seconds(const.exposureTimeSecond), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.output.state.accept(.complete)
            }).disposed(by: bag)
    }
}
