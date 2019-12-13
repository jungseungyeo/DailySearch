//
//  IntroViewController.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/13.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

class IntroViewController: BaseViewController {
    
    static func instance() -> IntroViewController {
        return IntroViewController(nibName: classNameToString, bundle: nil)
    }
    
    override func setup() {
        super.setup()
        
        addIndicator(activityView: view)
    }
    
    override func bind() {
        super.bind()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
