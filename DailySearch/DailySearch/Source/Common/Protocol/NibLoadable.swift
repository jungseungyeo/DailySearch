//
//  NibLoadable.swift
//  DailySearch
//
//  Created by saenglin on 2019/12/15.
//  Copyright © 2019 linsaeng. All rights reserved.
//

import UIKit

protocol NibLoadable {}

extension NibLoadable where Self: UIView {

    static func loadFromNib(with name: String? = nil) -> Self? {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: name ?? String(describing: self), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first

        return nibView as? Self
    }

    static var nib: UINib {
        let bundle = Bundle(for: self)
        return UINib(nibName: String(describing: self), bundle: bundle)
    }
}

extension UIView: NibLoadable {
    @objc
    class func instanceFromNib() -> Self? {
        return self.loadFromNib()
    }
}
