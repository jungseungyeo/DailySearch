//
//  SearchNetworker.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import Alamofire
import SwiftyJSON
import RxSwift
import RxCocoa

final class SearchNetworker {
    static func request(api: SearchAPI) -> Single<JSON> {
        return Networker.request(api: api)
    }
}
