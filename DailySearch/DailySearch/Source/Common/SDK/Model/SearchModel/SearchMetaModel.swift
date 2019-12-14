//
//  SearchMetaModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import ObjectMapper

final class SearchMetaModel: BaseModel {
    
    public private(set) var groupFilterGroups: Int?
    public private(set) var isEnd: Bool?
    public private(set) var pageableCount: Double?
    public private(set) var sessionID: Double?
    public private(set) var totalCount: Double?
    public private(set) var totalTime: Double?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        groupFilterGroups <- map["group_filter_groups"]
        isEnd <- map["is_end"]
        pageableCount <- map["pageable_count"]
        sessionID <- map["session_id"]
        totalCount <- map["total_count"]
        totalTime <- map["total_time"]
    }
}
