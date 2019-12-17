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
    
    private var viewModel: SearchWebPageViewModel!
    
    static func instance(viewModel: SearchWebPageViewModel) -> SearchWebPageViewController {
        let viewController = SearchWebPageViewController(nibName: classNameToString, bundle: nil)
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func setup() {
        super.setup()
        title = viewModel.titleString
        webView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.loadRequest(URLRequest(url: viewModel.requestURL))
    }
    
}

extension SearchWebPageViewController: UIWebViewDelegate {
    
}
