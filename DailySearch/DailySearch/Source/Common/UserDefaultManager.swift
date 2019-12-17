//
//  UserDefaultManager.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/17.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import Foundation

enum UserDefaultKey<T>: String, CustomStringConvertible {
    case clickUrls
    case recentList
    
    case testKey
    
    var description: String {
        return self.rawValue
    }
}

class UserDefaultManager: NSObject {
    
    private static let db = UserDefaults.standard

    private override init() { super.init() }
    
    @discardableResult
    static func setValue<T>(_ key: UserDefaultKey<T>, value: T) -> Bool {
        db.setValue(value, forKey: "\(key)")
        db.synchronize()
        
        return (self.getValue(key) ?? nil) != nil
    }
    
    static func getValue<T>(_ key: UserDefaultKey<T>) -> T? {
        return db.value(forKey: "\(key)") as? T
    }

    @discardableResult
    static func deleteValue<T>(_ key: UserDefaultKey<T>) -> Bool {
        db.removeObject(forKey: "\(key)")
        db.synchronize()
        return (self.getValue(key) ?? nil) == nil
    }
    
    static var clicUrls: [String]? {
        set { self.setValue(.clickUrls, value: newValue) }
        get { self.getValue(.clickUrls) }
    }
    
    static var recentList: [String]? {
        set { self.setValue(.recentList, value: newValue) }
        get { self.getValue(.recentList) }
    }
    
    static var testValue: Any? {
        set { self.setValue(.testKey, value: newValue) }
        get { self.getValue(.testKey) }
    }
}
