//
//  DailySearchService.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/13.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import Foundation

import Alamofire

final public class DailySearchService: NSObject {

    public var commonHeader: HTTPHeaders {
        var headers = HTTPHeaders()
        headers["Authorization"] = "KakaoAK e6ee92b352b11581c9a306e5dd81e37d"
        return headers
    }

    private var apiHost: String {
        return "dapi.kakao.com"
    }

    public var apiURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = apiHost
        return components.url!
    }

    public static let shared = DailySearchService()

    private override init() {
        super.init()
    }
}
