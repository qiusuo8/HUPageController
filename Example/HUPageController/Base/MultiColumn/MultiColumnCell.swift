//
//  MultiColumnCell.swift
//  HUPageController_Example
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

class MultiColumnCell: UICollectionViewCell {
    fileprivate lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = false
        view.contentMode = .scaleAspectFit
        return view
    }()

    var viewModel: MultiColumnRowViewModel? {
        didSet {
            if let vModel = viewModel {
                imageView.image = vModel.image
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white
        contentView.addSubview(imageView)

        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-2-[imageView]-2-|", options: NSLayoutFormatOptions(rawValue: UInt(0)), metrics: nil, views: ["imageView": imageView]))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[imageView]-2-|", options: NSLayoutFormatOptions(rawValue: UInt(0)), metrics: nil, views: ["imageView": imageView]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}

