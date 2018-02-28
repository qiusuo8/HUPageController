//
//  Reusable.swift
//  HUPageController_Example
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

public protocol Reusable: class {
    static var qsReuseIdentifier: String { get }
}

extension UITableViewCell: Reusable {
    public static var qsReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableViewHeaderFooterView: Reusable {
    public static var qsReuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: Reusable {
    public static var qsReuseIdentifier: String {
        return String(describing: self)
    }
}
