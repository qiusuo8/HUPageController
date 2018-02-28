//
//  OneColumnHeaderView.swift
//  HUPageController_Example
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

class OneColumnHeaderView: UICollectionReusableView {
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = UIColor.black.withAlphaComponent(0.54)
        view.textAlignment = .left
        view.numberOfLines = 1
        view.lineBreakMode = .byWordWrapping
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.addSubview(titleLabel)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[titleLabel]|", options: NSLayoutFormatOptions(rawValue: UInt(0)), metrics: nil, views: ["titleLabel": titleLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]|", options: NSLayoutFormatOptions(rawValue: UInt(0)), metrics: nil, views: ["titleLabel": titleLabel]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = ""
    }
}
