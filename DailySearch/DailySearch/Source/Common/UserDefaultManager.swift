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
    
    var description: String {
        return self.rawValue
    }
}

class UserDefaultManager: NSObject {
    
    private static let db = UserDefaults.standard

    private override init() { super.init() }
    
    private static func setValue<T>(_ key: UserDefaultKey<T>, value: T) {
        db.setValue(value, forKey: "\(key)")
        db.synchronize()
    }
    
    private static func getValue<T>(_ key: UserDefaultKey<T>) -> T? {
        return db.value(forKey: "\(key)") as? T
    }

    private static func deleteValue<T>(_ key: UserDefaultKey<T>) {
        db.removeObject(forKey: "\(key)")
        db.synchronize()
    }
}
