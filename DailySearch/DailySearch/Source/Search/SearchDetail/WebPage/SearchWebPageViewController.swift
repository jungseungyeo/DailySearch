//
//  SearchWebPageViewController.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/17.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit
import WebKit

class SearchWebPageViewController: BaseViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    private var requestURL: URL?
    
    static func instance(url: URL) -> SearchWebPageViewController {
        let viewController = SearchWebPageViewController(nibName: classNameToString, bundle: nil)
        viewController.requestURL = url
        return viewController
    }
    
    override func setup() {
        super.setup()
        
        webView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let requestURL = requestURL {
            webView.loadRequest(URLRequest(url: requestURL))
        }
    }
    
}

extension SearchWebPageViewController: UIWebViewDelegate {
    
}
