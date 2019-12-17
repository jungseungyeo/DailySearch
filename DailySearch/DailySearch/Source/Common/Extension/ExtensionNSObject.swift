//
//  ExtensionNSObject.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/13.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import Foundation

extension NSObject {
    static var classNameToString: String {
        return NSStringFromClass(self).components(separatedBy: ".").last ?? ""
    }
    
    enum StoryBoard: String, CustomStringConvertible {
        case search = "Search"
        
        var description: String {
            return self.rawValue
        }
    }
}
