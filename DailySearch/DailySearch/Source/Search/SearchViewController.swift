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
    
    @IBOutlet weak var searchListCollectionView: UICollectionView!
    
    private let viewModel = SearchViewModel()
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
                                  action: nil)
        btn.tintColor = DailySearchColor.Style.gray
        return btn
    }()
    
    private struct Const {
        let searchbarPlaceHolder: String = "검색어를 입력해주세요"
        let searchTitle: String = "검색"
        
        let searchFilterHeaderSize: CGSize = .init(width: UIScreen.main.bounds.width, height: 50)
        let searchListCellSize: CGSize = .init(width: UIScreen.main.bounds.width, height: 100)
        let recentSearchCellHeight: CGFloat = 50
    }
    
    private let const = Const()
    
    override func setup() {
        super.setup()
        setupKeyboard()
        setupNavigation()
        setupSearchListCollectionView()
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
    
    private func setupSearchListCollectionView() {
        searchListCollectionView.addSubviews(refreshControl)
        searchListCollectionView.register(UINib(nibName: "SearchFilterReusableView",
                                                bundle: nil),
                                          forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                          withReuseIdentifier: SearchFilterReusableView.registerID)
        
        searchListCollectionView.register(UINib(nibName: "SearchlistCollectionViewCell",
                                                bundle: nil),
                                          forCellWithReuseIdentifier: SearchlistCollectionViewCell.registerID)
    }
    
    override func bind() {
        super.bind()
        
        searchButton.rx.tap
            .map { [weak self] _ -> String in
                guard let self = self else { return "" }
                return self.searchbar.text ?? "" }
            .filter { $0.isNotEmpty() }
            .bind(to: viewModel.input.searchText)
            .disposed(by: bag)
        
        
        viewModel.output.genreFilterChoiceAlertObservable
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.showGenre()
            }).disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func showGenre() {
        let sheet = UIAlertController.genreSheet(handler: { [weak self] (searchType) in
            guard let self = self else { return }
            self.viewModel.input.searchTypeChanged.accept(searchType)
        })
        sheet.show(self)
    }
}

extension SearchViewController: UISearchBarDelegate {
    
}

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return const.searchFilterHeaderSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return const.searchListCellSize
    }
    
}

extension SearchViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 500
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: SearchFilterReusableView.registerID,
                                                                           for: indexPath) as? SearchFilterReusableView else {
                                                                            return UICollectionReusableView()
        }
        
        header.bind(type: viewModel.searchgenreType,
                    filterType: viewModel.searchListFilterType)
        
        header.rx.genreFilterBtnTapped
            .map { _ in return }
            .bind(to: viewModel.input.genreFilterBtnTapped)
            .disposed(by: header.bag)
        
        header.rx.listFileterBtnTapped
            .map { _ in return }
            .bind(to: viewModel.input.listFilterBtnTapped)
            .disposed(by: header.bag)
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchlistCollectionViewCell.registerID, for: indexPath) as? SearchlistCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        return cell
    }
}
