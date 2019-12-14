//
//  TestUtil.swift
//  DailySearchTests
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import Foundation

class TestUtil {
    static func loadJSON(_ fileName: String) -> Any? {
        guard let path = Bundle.init(for: TestUtil.self).path(forResource: fileName, ofType: "json") else {
            print("--- file not found : \(fileName).json")
            return nil
        }
        let fileURL = URL(fileURLWithPath: path)
        guard let data = try? Data.init(contentsOf: fileURL) else {
            print("--- can not access the file : \(fileName).json")
            return nil
        }
        let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return object
    }

    static func loadJSON(jsonString: String) -> Any? {
        if let data = jsonString.data(using: .utf8) {
            return loadJSON(data: data)
        }
        return nil
    }

    static func loadJSON(data: Data) -> Any? {
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
    }
}
