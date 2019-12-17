//
//  SearchListTableViewCell.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/15.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

import Kingfisher
import RxSwift
import RxCocoa

extension Reactive where Base: SearchListTableViewCell {
    var didTapCell: Observable<Void> {
        return base.didSelectedCell.rx.tap.asObservable()
    }
}

class SearchListTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var searchType: UILabel!
    @IBOutlet weak var typeName: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var typeDate: UILabel!
    @IBOutlet weak var thumbnailImg: UIImageView!

    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var didSelectedCell: UIButton!
    
    public var bag = DisposeBag()
    
    static let registerID = "\(SearchListTableViewCell.self)"
    
    private struct Const {
        let placeHoderImg: UIImage = UIImage(named: "linsaengLogo") ?? UIImage()
    }
    
    private let const = Const()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
        thumbnailImg.image = const.placeHoderImg
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        searchType.textColor = DailySearchColor.Style.label
        typeName.textColor = DailySearchColor.Style.label
        title.textColor = DailySearchColor.Style.label
        typeDate.textColor = DailySearchColor.Style.label
    }
    
    public func bind(isSelected: Bool, presentModel: SearchListPresentModel) {
        dimView.isHidden = !isSelected
        searchType.text = "\(presentModel.type)"
        typeName.attributedText = presentModel.title
        title.attributedText = presentModel.content
        typeDate.text = presentModel.dateTime
        
        if let thumbnailImageURL = URL(string: presentModel.thumbnailURLString) {
            thumbnailImg.kf.setImage(with: thumbnailImageURL, placeholder: const.placeHoderImg, options: .none, progressBlock: nil) { [weak self] (image, error, _, _) in
                guard let self = self else { return }
                guard error == nil, image != nil else {
                    // 이미지를 못 불러오거나 없는 경우
                    self.thumbnailImg.image = self.const.placeHoderImg
                    return
                }
            }
        }
    }
}
