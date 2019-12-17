//
//  SearchWebPageViewModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/17.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import Foundation

class SearchWebPageViewModel {
    
    public let requestURL: URL
    public let titleString: String
    
    init(url: URL, title: String) {
        requestURL = url
        titleString = title
    }
}
