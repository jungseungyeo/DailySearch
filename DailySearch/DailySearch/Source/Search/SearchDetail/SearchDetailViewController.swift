//
//  SearchDetailViewController.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/16.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

class SearchDetailViewController: BaseViewController {
    
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var searchName: UILabel!
    @IBOutlet weak var searchTitle: UILabel!
    @IBOutlet weak var searchContents: UILabel!
    @IBOutlet weak var createDate: UILabel!
    @IBOutlet weak var urlLink: UILabel!
    @IBOutlet weak var linkClickBtn: UIButton!
    
    private var viewModel: SearchDetailViewModel!
    private let bag = DisposeBag()
    
    static func instance(searchViewModel: SearchDetailViewModel) -> SearchDetailViewController {
        let searchDetailViewController = SearchDetailViewController(nibName: classNameToString, bundle: nil)
        searchDetailViewController.viewModel = searchViewModel
        return searchDetailViewController
    }
    
    private struct Const {
        let placeHoderImg: UIImage = UIImage(named: "linsaengLogo") ?? UIImage()
        let lineClickBtnTitle: String = "이동"
    }
    
    private let const = Const()
    
    override func setup() {
        super.setup()
        title = "\(viewModel.searchListPresentModel.type)"
        view.backgroundColor = DailySearchColor.Style.background
        setupThumbnailImage()
        setupSearchName()
        setupSearchContens()
        setupCreateDate()
        setupURL()
        setupLinkBtn()
    }
    
    private func setupThumbnailImage() {
        
        if let thumbnailURL = URL(string: viewModel.searchListPresentModel.thumbnailURLString) {
            thumbnailImage.kf.setImage(with: thumbnailURL,
                                       placeholder: const.placeHoderImg,
                                       options: nil,
                                       progressBlock: nil) { [weak self] (image, error, _, _) in
                                       guard let self = self else { return }
                                       guard error == nil, image != nil else {
                                           // 이미지를 못 불러오거나 없는 경우
                                           self.thumbnailImage.image = self.const.placeHoderImg
                                           return
                                       }
            }
        } else {
            thumbnailImage.image = const.placeHoderImg
        }
    }
    
    private func setupSearchName() {
        searchName.numberOfLines = 1
        searchName.textColor = DailySearchColor.Style.label
        searchName.text = "\(viewModel.searchListPresentModel.name)"
    }
    
    private func setupSearchTitle() {
        searchTitle.numberOfLines = 1
        searchTitle.attributedText = viewModel.searchListPresentModel.title
    }
    
    private func setupSearchContens() {
        searchContents.numberOfLines = 2
        searchContents.attributedText = viewModel.searchListPresentModel.content
    }
    
    private func setupCreateDate() {
        createDate.numberOfLines = 1
        createDate.textColor = DailySearchColor.Style.label
        createDate.text = viewModel.searchListPresentModel.detailDateTime
    }
    
    private func setupURL() {
        urlLink.numberOfLines = 1
        urlLink.textColor = DailySearchColor.Style.label
        urlLink.text = viewModel.searchListPresentModel.urlString
    }
    
    private func setupLinkBtn() {
        linkClickBtn.setTitle(const.lineClickBtnTitle, for: .normal)
        linkClickBtn.setTitleColor(DailySearchColor.Style.label, for: .normal)
        
        linkClickBtn.rx.tap
            .map { _ in return }
            .bind(to: viewModel.input.linkBtnTapped )
        .disposed(by: bag)
    }
    
    override func bind() {
        super.bind()
        
        viewModel.output.moveWebPage
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] (url) in
                guard let self = self else { return }
                self.navigationController?.pushViewController(SearchWebPageViewController.instance(url: url), animated: true)
            }).disposed(by: bag)
    }
    
}
