//
//  SearchModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import ObjectMapper

final class SearchModel: BaseModel {
    
    public private(set) var meta: SearchMetaModel?
    public private(set) var documents: [SearchDocumentModel]?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        meta <- map["meta"]
        documents <- map["documents"]
    }
}
