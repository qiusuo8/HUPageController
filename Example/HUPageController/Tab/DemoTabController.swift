//
//  DemoTabViewController.swift
//  HUPageController_Example
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import HUPageController

class DemoTabViewController: HUTabController {
    
    var dataProvider: DemoTabDataProvider = DemoTabDataProvider()
    
    fileprivate var isMultiColumn: Bool = true {
        didSet {
            floatBall.isSelected = !isMultiColumn
        }
    }
    
    private lazy var floatBall: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor.darkGray
        button.setTitle("One", for: UIControlState.normal)
        button.setTitle("Multi", for: UIControlState.selected)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 30
        button.addTarget(self, action: #selector(floatBallClick), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = "float ball"
        return button
    }()
    
    @objc private func floatBallClick() {
        isMultiColumn = !isMultiColumn
        updateTitle()
        reloadData()
    }
    
    private lazy var placeholderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.orange
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.lightGray
        
        tabBar.backgroundColor = UIColor.orange
        tabBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.black]
        tabBar.selectedTitleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.white]
        tabBar.selectionStyle = .fullWidthStripe
        tabBar.selectionIndicatorLocation = .down
        tabBar.selectionIndicatorColor = UIColor.white
        tabBar.selectionIndicatorHeight = 2.0
        tabBar.segmentWidthStyle = .dynamic
        tabBar.segmentEdgeInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        tabBar.layer.masksToBounds = false
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        tabBar.layer.shadowOpacity = 0.24
        tabBar.accessibilityLabel = "page example base tabBar"
        
        pageController.scrollView.backgroundColor = UIColor.lightGray
        pageController.scrollView.accessibilityLabel = "page example base scrollView"

        setUpFloatBall()

        dataProvider.successHandler = { [weak self] in
            self?.reloadData()
        }
        dataProvider.failHandler = { [weak self] (errorMessage) in
            self?.reloadData()
        }
        
        updateTitle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataProvider.fetchMultiColumns()

        dataProvider.fetchOneColumns()
    }
    
//    private func setupLayouts() {
//        view.addSubview(placeholderView)
//
//        var constraints = [
//            NSLayoutConstraint(item: placeholderView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0),
//            NSLayoutConstraint(item: placeholderView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0),
//            NSLayoutConstraint(item: placeholderView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0.5)
//        ]
//        if #available(iOS 11.0, *) {
//            constraints += [
//                placeholderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0)
//            ]
//        } else {
//            constraints += [
//                NSLayoutConstraint(item: placeholderView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0, constant: 0)
//            ]
//        }
//        constraints += [
//            NSLayoutConstraint(item: pageContoller.view, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0),
//            NSLayoutConstraint(item: pageContoller.view, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0),
//            NSLayoutConstraint(item: pageContoller.view, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0),
//            NSLayoutConstraint(item: pageContoller.view, attribute: .top, relatedBy: .equal, toItem: placeholderView, attribute: .bottom, multiplier: 1.0, constant: 0)
//        ]
//        NSLayoutConstraint.activate(constraints)
//    }
    
    private func setUpFloatBall() {
        view.addSubview(floatBall)
        let addConstraints = [
            NSLayoutConstraint(item: floatBall, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: -16),
            NSLayoutConstraint(item: floatBall, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -16),
            NSLayoutConstraint(item: floatBall, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60),
            NSLayoutConstraint(item: floatBall, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60)
        ]
        NSLayoutConstraint.activate(addConstraints)
    }
            
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    private func reloadData() {
        if isMultiColumn {
            reloadPages(with: dataProvider.multiColumnTitles, viewControllers: dataProvider.multiColumnControllers, selectIndex: 1)
        }else {
            reloadPages(with: dataProvider.oneColumnTitles, viewControllers: dataProvider.oneColumnControllers, selectIndex: 2)
        }
    }
    
    private func updateTitle() {
        navigationItem.title = isMultiColumn ? "Multi Column" : "One Column"
        navigationItem.accessibilityLabel = isMultiColumn ? "Multi Column" : "One Column"
    }
}
