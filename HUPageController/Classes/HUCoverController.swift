//
//  HUCoverController.swift
//  HUPageController
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

open class HUCoverController: HUTabController {
    
    open lazy var coverView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()

    open var coverHeight: CGFloat {
        return 100.0
    }
    
    open var coverOffsetY: CGFloat {
        return 0
    }
    
    fileprivate var coverTopLayout: NSLayoutConstraint?
    
    override open func loadView() {
        super.loadView()
        self.view.addSubview(coverView)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK:
    override func updateLayouts() {
        var addConstraints = [
            NSLayoutConstraint(item: coverView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0,constant: 0),
            NSLayoutConstraint(item: coverView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0,constant: 0),
            NSLayoutConstraint(item: coverView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0,constant: coverHeight)
        ]
        addConstraints += [
            NSLayoutConstraint(item: tabBar, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0,constant: 0),
            NSLayoutConstraint(item: tabBar, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0,constant: 0),
            NSLayoutConstraint(item: tabBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0,constant: segmentHeight),
            NSLayoutConstraint(item: tabBar, attribute: .top, relatedBy: .equal, toItem: coverView, attribute: .bottom, multiplier: 1.0,constant: 0)
        ]
        addConstraints += [
            NSLayoutConstraint(item: pageController.view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0,constant: 0),
            NSLayoutConstraint(item: pageController.view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0,constant: 0),
        ]
        if #available(iOS 11.0, *) {
            coverTopLayout = coverView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: coverOffsetY)
            addConstraints += [
                coverTopLayout!,
                pageController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                pageController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            ]
        } else {
            coverTopLayout = NSLayoutConstraint(item: coverView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0,constant: coverOffsetY)
            addConstraints += [
                coverTopLayout!,
                NSLayoutConstraint(item: pageController.view, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0,constant: 0),
                NSLayoutConstraint(item: pageController.view, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1.0,constant: 0)
            ]
        }
        NSLayoutConstraint.activate(addConstraints)
    }

    public func pageController(_ pageController: HUPageController, maxOffsetFromTopAt index: Int) -> CGFloat {
        return coverHeight + segmentHeight + coverOffsetY
    }
    
    public func pageController(_ pageController: HUPageController, minOffsetFromTopAt index: Int) -> CGFloat {
        return segmentHeight
    }
    
    public func pageController(_ pageController: HUPageController, currentOffsetFromTopAt index: Int) -> CGFloat {
        if let coverTopLayout = coverTopLayout {
            return coverTopLayout.constant + coverHeight + segmentHeight
        }
        return coverHeight + segmentHeight
    }

    open func pageController(_ pageController: HUPageController, scroll verticalOffset: CGFloat, at index: Int) {
        if let coverTopLayout = coverTopLayout {
            let minY: CGFloat = -coverHeight
            let maxY: CGFloat = coverOffsetY
            let maxOffsetFromTop: CGFloat = self.pageController(pageController, maxOffsetFromTopAt: index)
            
            var willOriginY: CGFloat = coverOffsetY - (maxOffsetFromTop + verticalOffset)
            
            if willOriginY <= minY {
                willOriginY = minY
            } else if willOriginY >= maxY {
                willOriginY = maxY
            } else {
                updateCoverViewFrame(withOriginY: willOriginY)
            }
            
            if willOriginY == minY, coverTopLayout.constant > minY {
                updateCoverViewFrame(withOriginY: willOriginY)
            } else if willOriginY == maxY, coverTopLayout.constant < maxY {
                updateCoverViewFrame(withOriginY: willOriginY)
            }
        }
    }
    
    func updateCoverViewFrame(withOriginY: CGFloat) {
        coverTopLayout?.constant = withOriginY
        self.view.layoutIfNeeded()
    }
}
