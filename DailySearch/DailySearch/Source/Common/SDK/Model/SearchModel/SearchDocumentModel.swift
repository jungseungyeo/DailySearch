//
//  SearchDocumentsModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import ObjectMapper

public enum SearchType: String, CustomStringConvertible {
    case all = "All"
    case blog = "Blog"
    case cafe = "Cafe"
    
    public var description: String {
        return self.rawValue
    }
}

final class SearchDocumentModel: BaseModel {

    public private(set) var searchType: SearchType?
    
    /// Cafe or Blog name
    public private(set) var typeName: String?
    
    public private(set) var contents: String?
    public private(set) var dateTime: String?
    public private(set) var thumbnail: String?
    public private(set) var title: String?
    public private(set) var url: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        contents <- map["contents"]
        dateTime <- map["datetime"]
        thumbnail <- map["thumbnail"]
        title <- map["title"]
        url <- map["url"]
        
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
