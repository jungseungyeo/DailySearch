//
//  ExtensionReactive.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/15.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import RxSwift

extension ObservableType {
    func flatMapLatest<A: AnyObject, O: ObservableType>(weak obj: A, selector: @escaping (A, Self.Element) throws -> O) -> Observable<O.Element> {
        return flatMapLatest { [weak obj] value -> Observable<O.Element> in
            try obj.map { try selector($0, value).asObservable() } ?? .empty()
        }
    }
}
