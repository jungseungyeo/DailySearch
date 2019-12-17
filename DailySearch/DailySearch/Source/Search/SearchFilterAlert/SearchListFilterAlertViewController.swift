//
//  SearchListFilterAlertViewController.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/15.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

protocol SearchListFilterDelegate: class {
    func confirm(type: SearchListFilter)
    func cancel()
}

class SearchListFilterAlertViewController: BaseViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterTableView: UITableView!
    
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    weak var delegate: SearchListFilterDelegate?
    
    private var viewModel: SearchListAlertViewModel?
    private let bag = DisposeBag()
    
    static func intance(viewModel: SearchListAlertViewModel) -> SearchListFilterAlertViewController {
        let searchListFilterAlertViewController = SearchListFilterAlertViewController(nibName: classNameToString,
                                                                                      bundle: nil)
        searchListFilterAlertViewController.viewModel = viewModel
        return searchListFilterAlertViewController
    }
    
    private struct Const {
        let filterSelectedCellHeight: CGFloat = 75
        let contentViewRadius: CGFloat = 20
        let backgroundColor: UIColor = DailySearchColor.Style.gray.withAlphaComponent(0.1)
    }
    
    private let const = Const()
    
    override func setup() {
        super.setup()
        contentView.layer.cornerRadius = const.contentViewRadius
        contentView.clipsToBounds = true
        view.backgroundColor = const.backgroundColor
        confirmBtn.setTitleColor(DailySearchColor.Style.label, for: .normal)
        cancelBtn.setTitleColor(DailySearchColor.Style.label, for: .normal)
        
        setupFilterTableView()
    }
    
    private func setupFilterTableView() {
        filterTableView.register(UINib(nibName: "SearchListFilterAlertTableViewCell",
                                       bundle: nil),
                                 forCellReuseIdentifier: SearchListFilterAlertTableViewCell.registerID)
        filterTableView.bounces = false
        filterTableView.tableFooterView = UIView()
    }
    
    override func bind() {
        super.bind()
        
        confirmBtn.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.delegate?.confirm(type: self.viewModel?.currentFilterType ?? .title)
                self.dimissAnimation()
            }).disposed(by: bag)
        
        cancelBtn.rx.tap
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return }
                self.delegate?.cancel()
                self.dimissAnimation()
            }).disposed(by: bag)
        
        viewModel?.output.reloadTable
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (_) in
                guard let self = self else { return}
                self.filterTableView.reloadData()
            }).disposed(by: bag)
    }
    
    private func dimissAnimation() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: false, completion: nil)
        })
    }
}

extension SearchListFilterAlertViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.input.selectedFilter.accept(indexPath.row)
    }
}

extension SearchListFilterAlertViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchListFilter.allCases.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return const.filterSelectedCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel, let cell = tableView.dequeueReusableCell(withIdentifier: SearchListFilterAlertTableViewCell.registerID,
                                                       for: indexPath) as? SearchListFilterAlertTableViewCell else {
                                                        return UITableViewCell()
        }
        
        cell.bind(isSelected: viewModel.isSelectedType(to: indexPath.row),
                  filterText: viewModel.filterText(to: indexPath.row))
        
        return cell
    }
    
    
}
