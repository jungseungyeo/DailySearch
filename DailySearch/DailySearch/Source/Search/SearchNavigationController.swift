//
//  SearchNavigationController.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

class SearchNavigationController: BaseNavigationViewController {
    
    static func instance() -> SearchNavigationController? {
        return UIStoryboard(name: "\(StoryBoard.search)", bundle: nil).instantiateViewController(withIdentifier: classNameToString) as? SearchNavigationController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
