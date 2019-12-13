//
//  DailySearchColor.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/13.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

class DailySearchColor: NSObject {
    
      struct Style {
          static var background: UIColor {
              if #available(iOS 13, *) {
                  return .systemBackground
              }
              return .white
          }
          
          static var label: UIColor {
              if #available(iOS 13, *) {
                  return .label
              }
              return .black
          }
          
          static var gray: UIColor {
              if #available(iOS 13, *) {
                  return .systemGray
              }
              return .gray
          }
      }

}
