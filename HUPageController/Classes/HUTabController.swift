//
//  HUTabController.swift
//  HUPageController
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

open class HUTabController: UIViewController, HUPageControllerDelegate, HUPageControllerDataSource {
    
    open lazy var tabBar: HMSegmentedControl = {
        let segmentedControl = HMSegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.backgroundColor = UIColor.white
        segmentedControl.selectionIndicatorLocation = .down
        segmentedControl.selectionStyle = .textWidthStripe
        segmentedControl.selectionIndicatorColor = UIColor.orange
        segmentedControl.selectionIndicatorHeight = 8
        segmentedControl.segmentWidthStyle = .fixed
        return segmentedControl
    }()
    
    open lazy var pageController: HUPageController = {
        let controller = HUPageController()
        return controller
    }()
    
    open var segmentHeight: CGFloat {
        return 44.0
    }
    
    fileprivate(set) var pageTitles: [String] = []
    fileprivate(set) public var viewControllers: [UIViewController] = []
    
    //MARK: - Lift Cycles
    open override func loadView() {
        super.loadView()
        
        pageController.delegate = self
        pageController.dataSource = self

        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        pageController.willMove(toParentViewController: self)
        self.addChildViewController(pageController)
        self.view.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)
        
        self.view.addSubview(tabBar)
        tabBar.indexChangeBlock = { [weak self] index in
            self?.segmentedControDidSelect(index: index)
        }
        tabBar.titleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.black]
        tabBar.selectedTitleTextAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.black]
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        updateLayouts()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pageController.beginAppearanceTransition(true, animated: animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pageController.endAppearanceTransition()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pageController.beginAppearanceTransition(false, animated: animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        pageController.endAppearanceTransition()
    }
    
    override open var shouldAutorotate: Bool {
        return true
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //MARK: custom methods
    open func reloadPages(with titles: [String], viewControllers: [UIViewController], selectIndex: Int) {
        if titles.count == viewControllers.count {
            self.pageTitles = titles
            if titles.count > 0 {
                tabBar.sectionTitles = titles
            }

            if titles.count == 0 {
                tabBar.selectedSegmentIndex = HMSegmentedControlNoSegment
                tabBar.isHidden = true
            } else {
                tabBar.selectedSegmentIndex = selectIndex
                tabBar.isHidden = false
            }
            self.viewControllers = viewControllers
            pageController.reloadPageAtIndex(selectIndex, animated: false, clearCache: true)
        } else {
        }
    }
    
    //MARK: - Subviews Configuration
    func updateLayouts() {
        var addConstraints = [
            NSLayoutConstraint(item: tabBar, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0,constant: 0),
            NSLayoutConstraint(item: tabBar, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0,constant: 0),
            NSLayoutConstraint(item: tabBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0,constant: segmentHeight),
            NSLayoutConstraint(item: pageController.view, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0,constant: 0),
            NSLayoutConstraint(item: pageController.view, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0,constant: 0),
            NSLayoutConstraint(item: pageController.view, attribute: .top, relatedBy: .equal, toItem: tabBar, attribute: .bottom, multiplier: 1.0,constant: 0)
        ]
        if #available(iOS 11.0, *) {
            addConstraints += [
                tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                pageController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            ]
        } else {
            addConstraints += [
                NSLayoutConstraint(item: tabBar, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0,constant: 0),
                NSLayoutConstraint(item: pageController.view, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1.0,constant: 0)
            ]
        }
        NSLayoutConstraint.activate(addConstraints)
    }
    
    open func segmentedControDidSelect(index: Int) {
        pageController.showPageAtIndex(index, animated: true)
    }    
}

extension HUTabController {
    public func numberOfControllers(_: HUPageController) -> Int {
        return viewControllers.count
    }
    
    public func pageController(_: HUPageController, controllerAtIndex index: Int) -> UIViewController {
        return viewControllers[index]
    }
    
    open func pageController(_ pageController: HUPageController, didLeaveFrom fromIndex: Int, toIndex: Int, progress: Double) {
        tabBar.scroll(from: fromIndex, to: toIndex, with: CGFloat(progress))
    }
    
    open func pageController(_ pageController: HUPageController, didLeaveFrom fromIndex: Int, toIndex: Int, animated: Bool, isScrolling: Bool) {
        if isScrolling {
            tabBar.setSelectedSegmentIndex(UInt(toIndex), animated: true)
        }
    }
    
    open func screenEdgePanGestureRecognizerForPageController(_: HUPageController) -> UIScreenEdgePanGestureRecognizer? {
        if let gestureRecognizers = navigationController?.view.gestureRecognizers, gestureRecognizers.count > 0 {
            for gesture in gestureRecognizers {
                if gesture.isKind(of: UIScreenEdgePanGestureRecognizer.self) {
                    return gesture as? UIScreenEdgePanGestureRecognizer
                }
            }
        }
        return nil
    }
}
