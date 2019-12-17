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

enum SearchViewControllerTableViewType: Int {
    case searchList = 1
    case recnetList = 2
    
    var tag: Int {
        return self.rawValue
    }

}

class SearchViewController: BaseViewController {
    
    @IBOutlet weak var searchListTableView: UITableView!
    @IBOutlet weak var recentSearchListTableView: UITableView!
    @IBOutlet weak var recentSearchListTableViewHeight: NSLayoutConstraint!
    
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
        
        let searchFilterHeaderHeight: CGFloat = 50
        let saerchListHeight: CGFloat = 143
        
        let recentCellHeight: CGFloat = 45
        let recentTableMaxHeight: CGFloat = 225
    }
    
    private let const = Const()
    
    override func setup() {
        super.setup()
        title = ""
        setupKeyboard()
        setupNavigation()
        setupSearchListTableView()
        setupRecentListTableView()
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
    
    private func setupSearchListTableView() {
        searchListTableView.tag = SearchViewControllerTableViewType.searchList.tag
        searchListTableView.separatorStyle = .singleLine
        searchListTableView.tableFooterView = UIView()
        searchListTableView.register(UINib(nibName: "SearchListTableViewCell", bundle: nil),
                                     forCellReuseIdentifier: SearchListTableViewCell.registerID)
    }
    
    private func setupRecentListTableView() {
        recentSearchListTableView.tag = SearchViewControllerTableViewType.recnetList.tag
        recentSearchListTableView.bounces = false
        recentSearchListTableView.isHidden = true
        recentSearchListTableView.separatorStyle = .singleLine
        recentSearchListTableView.tableFooterView = UIView()
        recentSearchListTableView.register(UINib(nibName: "RecentSearchListTableViewCell", bundle: nil),
                                           forCellReuseIdentifier: RecentSearchListTableViewCell.registerID)
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
        
        viewModel.output.listFilterChoiceAlert
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (searchFilterViewController) in
                guard let self = self else { return }
                self.showListFilter(to: searchFilterViewController)
            }).disposed(by: bag)
        
        viewModel.output.state
            .subscribe(onNext: { [weak self] (state) in
                guard let self = self else { return }
                switch state {
                case .requesting:
                    self.searchbar.endEditing(true)
                    self.indicator.startAnimating()
                case .complete:
                    self.indicator.stopAnimating()
                    self.searchListTableView.reloadData()
                case .error(let error):
                    self.indicator.stopAnimating()
                    self.handleError(error: error)
                }
                
            }).disposed(by: bag)
        
        viewModel.output.moveDetailView
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (searchDetailViewController) in
                guard let self = self else { return }
                self.searchbar.endEditing(true)
                self.recentSearchListTableView.isHidden = true
                self.navigationController?.pushViewController(searchDetailViewController, animated: true)
            }).disposed(by: bag)
        
        viewModel.output.isRecentShow
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (isShow) in
                guard let self = self else { return }
                let height = CGFloat((UserDefaultManager.recentList?.count ?? 0)) * self.const.recentCellHeight
                self.recentSearchListTableViewHeight.constant = height < self.const.recentTableMaxHeight ? height : self.const.recentTableMaxHeight
                self.recentSearchListTableView.reloadData()
                self.recentSearchListTableView.isHidden = isShow
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
    
    private func showListFilter(to searchListFilterAlertViewController: SearchListFilterAlertViewController) {
        let filterAlertViewController = searchListFilterAlertViewController
        
        filterAlertViewController.modalPresentationStyle = .overFullScreen
        filterAlertViewController.delegate = self
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.present(filterAlertViewController,
                         animated: false,
                         completion: nil)
        })
    }
    
    override func handleError(error: Error?) {
        super.handleError(error: error)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchListTableView.reloadData()
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let type = SearchViewControllerTableViewType.init(rawValue: tableView.tag) else { return }
        switch type {
        case .searchList:
            searchListTableView(tableView, didSelectRowAt: indexPath)
        case .recnetList:
            recentTableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let type = SearchViewControllerTableViewType.init(rawValue: tableView.tag) else { return }
        switch type {
        case .searchList:
            searchListTableView(tableView, willDisplay: cell, forRowAt: indexPath)
        case .recnetList:
            recentTableView(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let type = SearchViewControllerTableViewType.init(rawValue: tableView.tag) else { return 0 }
        switch type {
        case .searchList:
            return searchListTableView(tableView, numberOfRowsInSection: section)
        case .recnetList:
            return recentTableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let type = SearchViewControllerTableViewType.init(rawValue: tableView.tag) else { return 0 }
        switch type {
        case .searchList:
            return searchListTableView(tableView, heightForHeaderInSection: section)
        case .recnetList:
            return recentTableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let type = SearchViewControllerTableViewType.init(rawValue: tableView.tag) else { return 0 }
        switch type {
        case .searchList:
            return searchListTableView(tableView, heightForRowAt: indexPath)
        case .recnetList:
            return recentTableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let type = SearchViewControllerTableViewType.init(rawValue: tableView.tag) else { return nil }
        switch type {
        case .searchList:
            return searchListTableView(tableView, viewForHeaderInSection: section)
        case .recnetList:
            return recentTableView(tableView, viewForHeaderInSection: section)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = SearchViewControllerTableViewType.init(rawValue: tableView.tag) else { return UITableViewCell() }
        switch type {
        case .searchList:
            return searchListTableView(tableView, cellForRowAt: indexPath)
        case .recnetList:
            return recentTableView(tableView, cellForRowAt: indexPath)
        }
    }
}

extension SearchViewController {
    
    func searchListTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func searchListTableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if viewModel.searchListPresentModels.count - 3 == indexPath.row {
            viewModel.input.pagingRequet.accept(())
        }
    }
    
    func searchListTableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return const.searchFilterHeaderHeight
    }
    
    func searchListTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchListPresentModels.count
    }
    
    func searchListTableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return const.saerchListHeight
    }
    
    func searchListTableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerFilterView = SearchFilterHeaderView.loadFromNib() else {
            return nil
        }
        
        headerFilterView.bind(type: viewModel.searchgenreType,
                              filterType: viewModel.searchListFilterType)
        
        headerFilterView.rx.genreFilterBtnTapped
            .map { _ in return }
            .bind(to: viewModel.input.genreFilterBtnTapped)
            .disposed(by: headerFilterView.bag)
        
        headerFilterView.rx.listFileterBtnTapped
            .map { _ in return }
            .bind(to: viewModel.input.listFilterBtnTapped)
            .disposed(by: headerFilterView.bag)
        
        return headerFilterView
    }
    
    func searchListTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchListTableViewCell.registerID, for: indexPath) as? SearchListTableViewCell else {
            return UITableViewCell()
        }
    
        guard let presentModel = viewModel.searchListPresentModels[safe: indexPath.row] else { return cell }
        
        cell.bind(isSelected: viewModel.isDimCell(indexPath.row),
                  presentModel: presentModel)
        
        cell.rx.didTapCell
            .map { _ -> Int in
                return indexPath.row
        }.bind(to: viewModel.input.didTapped)
            .disposed(by: cell.bag)
        return cell
    }
}

extension SearchViewController {
    
    func recentTableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func recentTableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    
    func recentTableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func recentTableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.recentListCount
    }
    
    func recentTableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return const.recentCellHeight
    }
    
    func recentTableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func recentTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchListTableViewCell.registerID, for: indexPath) as? RecentSearchListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.bind(viewModel.recentSearchText(indexPath.row))
        
        cell.rx.recetnCellTapped
            .filter { [weak self] (recentTitle) -> Bool in
                guard let self = self else { return false }
                self.searchbar.text = recentTitle
                return (recentTitle ?? "").isNotEmpty()
        }.map { $0 ?? "" }
            .bind(to: viewModel.input.searchText)
            .disposed(by: cell.bag)
        
        return cell
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        viewModel.input.searchTapped.accept(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        viewModel.input.searchTapped.accept(false)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchbar.text else { return }
        viewModel.input.searchText.accept(searchText)
    }
}

extension SearchViewController: SearchListFilterDelegate {
    func confirm(type: SearchListFilter) {
        viewModel.input.searchListTypeChanged.accept(type)
    }
    
    func cancel() { }
}
