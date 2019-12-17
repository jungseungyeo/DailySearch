//
//  UserDefaultTest.swift
//  DailySearchTests
//
//  Created by saenglin on 2019/12/17.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import XCTest
@testable import DailySearch

class UserDefaultTest: XCTestCase {
    
    func testSave() {
        let result = UserDefaultManager.setValue(.testKey, value: 1)
        XCTAssertTrue(result)
    }
    
    func testDelete() {
        UserDefaultManager.setValue(.testKey, value: 1)
        let result = UserDefaultManager.deleteValue(UserDefaultKey<Int>.testKey)
        XCTAssertTrue(result)
    }
    
    func testGetValue() {
        UserDefaultManager.setValue(.testKey, value: 1)
        
        guard let value = UserDefaultManager.getValue(UserDefaultKey<Int>.testKey) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(value, 1)
        let result = UserDefaultManager.deleteValue(UserDefaultKey<Int>.testKey)
        XCTAssertTrue(result)
    }
    
    func testValue() {
        let testValueArray: [String] = ["test", "testValue"]
        UserDefaultManager.testValue = testValueArray
        
        guard let value = UserDefaultManager.testValue as? [String] else {
            XCTFail()
            return
        }
        
        for (index, value) in value.enumerated() {
            XCTAssertEqual(testValueArray[index], value)
        }
    }
}
