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
    
    @IBOutlet weak var searchListTableView: UITableView!
    
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
    }
    
    private let const = Const()
    
    override func setup() {
        super.setup()
        setupKeyboard()
        setupNavigation()
        setupSearchListTableView()
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
        searchListTableView.separatorStyle = .singleLine
        searchListTableView.tableFooterView = UIView()
        searchListTableView.register(UINib(nibName: "SearchListTableViewCell", bundle: nil),
                                     forCellReuseIdentifier: SearchListTableViewCell.registerID)
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
                    self.indicator.startAnimating()
                case .complete:
                    self.indicator.stopAnimating()
                    self.searchListTableView.reloadData()
                case .error(let error):
                    self.indicator.stopAnimating()
                    self.handleError(error: error)
                }
                
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
}

extension SearchViewController: UITableViewDelegate {
    
}

extension SearchViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchListPresentModels.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return const.searchFilterHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return const.saerchListHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchListTableViewCell.registerID, for: indexPath) as? SearchListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.bind(isSelected: false,
                  presentModel: viewModel.searchListPresentModels[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if viewModel.searchListPresentModels.count - 3 == indexPath.row {
            viewModel.input.pagingRequet.accept(())
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
}

extension SearchViewController: SearchListFilterDelegate {
    func confirm(type: SearchListFilter) {
        viewModel.input.searchListTypeChanged.accept(type)
    }
    
    func cancel() { }
}
