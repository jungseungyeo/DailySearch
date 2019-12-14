//
//  SearchListFilterAlertViewController.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/15.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

class SearchListFilterAlertViewController: BaseViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var filterTableView: UITableView!
    
    static func intance() -> SearchListFilterAlertViewController {
        return SearchListFilterAlertViewController(nibName: classNameToString, bundle: nil)
    }
    
    override func setup() {
        super.setup()
        contentView.layer.cornerRadius = 20
        contentView.clipsToBounds = true
        view.backgroundColor = DailySearchColor.Style.gray.withAlphaComponent(0.1)
        
        setupFilterTableView()
    }
    
    private func setupFilterTableView() {
        filterTableView.register(UINib(nibName: "SearchListFilterAlertTableViewCell",
                                       bundle: nil),
                                 forCellReuseIdentifier: SearchListFilterAlertTableViewCell.registerID)
        filterTableView.bounces = false
        filterTableView.tableFooterView = UIView()
    }
}

extension SearchListFilterAlertViewController: UITableViewDelegate {
    
}

extension SearchListFilterAlertViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchListFilterAlertTableViewCell.registerID,
                                                       for: indexPath) as? SearchListFilterAlertTableViewCell else {
                                                        return UITableViewCell()
        }
        
        return cell
    }
    
    
}
