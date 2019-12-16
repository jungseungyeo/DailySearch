//
//  BaseViewController.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/13.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

import SnapKit

protocol BaseViewControllerable {
    func setup()
    func bind()
    func addIndicator(activityView: UIView)
    func handleError(error: Error?)
}

class BaseViewController: UIViewController, BaseViewControllerable {
    
    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: indicatorStyle)
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        return indicator
    }()
    
    private var indicatorStyle: UIActivityIndicatorView.Style {
        if #available(iOS 13, *) {
            return .medium
        }
        return .gray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
    public func setup() { }
    public func bind() { }
    
    public func addIndicator(activityView: UIView) {
        activityView.addSubview(indicator)
        
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    public func handleError(error: Error?) { }
    
    public func setUp(title: String?) {
        guard let title = title else { return }
        self.navigationItem.title = title
    }
}
