//
//  SearchViewController.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/14.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

class SearchViewController: BaseViewController {
    
    private let bag = DisposeBag()
    
    private lazy var searchbar: UISearchBar = {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.placeholder = const.searchbarPlaceHolder
        searchBar.isTranslucent = false
        searchBar.returnKeyType = .search
        searchBar.backgroundImage = UIImage()
        searchBar.tintColor = DailySearchColor.Style.label
        searchBar.keyboardType = .default
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var searchButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: const.searchTitle,
                                  style: .done,
                                  target: self,
                                  action: #selector(searchTapped(sender:)))
        btn.tintColor = DailySearchColor.Style.gray
        return btn
    }()
    
    private struct Const {
        let searchbarPlaceHolder: String = "검색어를 입력해주세요"
        let searchTitle: String = "검색"
        
        let searchListCellSize: CGSize = .init(width: UIScreen.main.bounds.width, height: 100)
        let recentSearchCellHeight: CGFloat = 50
    }
    
    private let const = Const()
    
    override func setup() {
        super.setup()
        setupKeyboard()
        setupNavigation()
    }
    
    private func setupKeyboard() {
        let singleTapGestureRecognizer = UITapGestureRecognizer()
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = true
        view.addGestureRecognizer(singleTapGestureRecognizer)
        singleTapGestureRecognizer.rx
            .event
            .subscribeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.searchbar.endEditing(true)
            })
            .disposed(by: bag)
    }
    
    private func setupNavigation() {
        navigationItem.titleView = searchbar
        navigationItem.rightBarButtonItem = searchButton
    }
    
    override func bind() {
        super.bind()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension SearchViewController: UISearchBarDelegate {
    @objc
    func searchTapped(sender: UIBarButtonItem) {
        
    }
}
