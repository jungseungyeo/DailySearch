//
//  BaseModel.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import ObjectMapper

class BaseModel: Mappable {
    
    required init?(map: Map) { }
    func mapping(map: Map) { }
}
