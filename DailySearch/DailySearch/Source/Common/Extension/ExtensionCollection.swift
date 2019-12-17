//
//  ExtensionCollection.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/17.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import Foundation
public extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
