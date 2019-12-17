//
//  SearchAPI.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import Alamofire

enum SearchSortType: String, CustomStringConvertible {
    case accuracy
    case recency
    
    var description: String {
        return self.rawValue
    }
}

enum SearchAPI {
    case blog(query: String, sort: SearchSortType, page: Int, size: Int)
    case cafe(query: String, sort: SearchSortType, page: Int, size: Int)
}

extension SearchAPI: Networkerable {
    var route: (method: HTTPMethod, url: URL) {
        switch self {
        case .blog:
            return (.get, DailySearchService.shared.apiURL
                .appendingPathComponent("v2")
                .appendingPathComponent("search")
                .appendingPathComponent("blog"))
        case .cafe:
            return (.get, DailySearchService.shared.apiURL
                .appendingPathComponent("v2")
                .appendingPathComponent("search")
                .appendingPathComponent("cafe"))
        }
    }
    
    var params: Parameters? {
        var params = Parameters()
        switch self {
        case .blog(let query, let sort, let page, let size),
             .cafe(let query, let sort, let page, let size):
            params["query"] = query
            params["sort"] = "\(sort)"
            params["page"] = page
            params["size"] = size
            return params
        }
    }
    
    var header: HTTPHeaders? { return nil }
}
