//
//  SearchDocumentsModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import ObjectMapper

enum SearchType {
    case blog
    case cafe
}

final class SearchDocumentModel: BaseModel {

    public private(set) var searchType: SearchType?
    
    /// Cafe or Blog name
    public private(set) var typeName: String?
    
    public private(set) var contents: String?
    public private(set) var dateTime: Date?
    public private(set) var thumbnail: URL?
    public private(set) var title: String?
    public private(set) var url: URL?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        contents <- map["contents"]
        dateTime <- (map["datetime"], DateTransform())
        thumbnail <- (map["thumbnail"], URLTransform())
        title <- map["title"]
        url <- (map["url"], URLTransform())
        
        typeName <- map["cafename"]
        
        if typeName != nil {
            // cafe
            searchType = .cafe
        } else {
            // blog
            searchType = .blog
            typeName <- map["blogname"]
        }
    }
}
