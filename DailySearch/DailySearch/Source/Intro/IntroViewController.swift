//
//  IntroViewController.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/13.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

class IntroViewController: BaseViewController {
    
    private let viewModel = IntroViewModel()
    private let bag = DisposeBag()
    
    static func instance() -> IntroViewController {
        return IntroViewController(nibName: classNameToString, bundle: nil)
    }
    
    override func setup() {
        super.setup()
        
        addIndicator(activityView: view)
        
        view.backgroundColor = DailySearchColor.Style.background
    }
    
    override func bind() {
        super.bind()
        
        viewModel.output.state
            .subscribe(onNext: { [weak self] (state) in
                guard let self = self else { return }
                switch state {
                case .requesting:
                    self.indicator.startAnimating()
                case .complete:
                    self.indicator.stopAnimating()
                    self.moveSearchPage()
                case .error(let error):
                    self.indicator.stopAnimating()
                    self.handleError(error: error)
                }
                
            }).disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.input.request.accept(())
    }
    
    override func handleError(error: Error?) {
        super.handleError(error: error)
        
        NetworkError().alert(vc: self,
                             error: error) { errorCode in
                                UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        }
    }
}

private extension IntroViewController {
    func moveSearchPage() {
        guard let window = UIApplication.shared.windows.first else { return }
        guard let searchNavigationController = SearchNavigationController.instance() else {
            return
        }
        searchNavigationController.view.alpha = 0.0
        UIApplication.shared.windows.first?.rootViewController = searchNavigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
        UIView.transition(with: window, duration: 0.3, options: [.transitionCrossDissolve], animations: {
            searchNavigationController.view.alpha = 1.0
        }, completion: nil)
    }
}
