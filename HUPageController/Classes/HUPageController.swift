//
//  HUPageController.swift
//  HUPageController
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

enum HUPageScrollDirection {
    case left
    case right
}

@objc public protocol HUPageControllerDataSource {
    func numberOfControllers(_: HUPageController) -> Int
    func pageController(_: HUPageController, controllerAtIndex index: Int) -> UIViewController
}

@objc public protocol HUPageControllerDelegate {
    @objc optional func pageController(_ pageController: HUPageController, willLeaveFrom fromIndex: Int, toIndex: Int, animated: Bool, isScrolling: Bool)
    @objc optional func pageController(_ pageController: HUPageController, didLeaveFrom fromIndex: Int, toIndex: Int, animated: Bool, isScrolling: Bool)
    @objc optional func pageController(_ pageController: HUPageController, didLeaveFrom fromIndex: Int, toIndex: Int, progress: Double)
    
    @objc optional func pageController(_ pageController: HUPageController, maxOffsetFromTopAt index: Int) -> CGFloat
    @objc optional func pageController(_ pageController: HUPageController, minOffsetFromTopAt index: Int) -> CGFloat
    @objc optional func pageController(_ pageController: HUPageController, currentOffsetFromTopAt index: Int) -> CGFloat
    @objc optional func pageController(_ pageController: HUPageController, scroll verticalOffset: CGFloat, at index: Int)
    
    @objc optional func screenEdgePanGestureRecognizerForPageController(_ :HUPageController) -> UIScreenEdgePanGestureRecognizer?
}

@objc public protocol HUPageSubController {
    @objc optional func mainScrollView() -> UIScrollView
}



open class HUPageController: UIViewController, UIScrollViewDelegate, NSCacheDelegate {
    open weak var delegate: HUPageControllerDelegate?
    open weak var dataSource: HUPageControllerDataSource?
    
    open var contentEdgeInsets = UIEdgeInsets.zero
    
    open var pageCount: Int {
        if let source = dataSource {
            return source.numberOfControllers(self)
        }
        return 0
    }
    
    open var cacheLimit: Int {
        get {
            return self.memCache.countLimit
        }
        set {
            self.memCache.countLimit = newValue;
        }
    }

    fileprivate(set) open lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.isPagingEnabled = true
        view.backgroundColor = UIColor.clear
        view.scrollsToTop = false
        return view
    }()
    
    fileprivate var currentPage: UIViewController? {
        return controllerAtIndex(currentPageIndex)
    }

    fileprivate(set) open var currentPageIndex = 0
    fileprivate lazy var memCache: NSCache<NSNumber, UIViewController> = {
        let cache = NSCache<NSNumber, UIViewController>()
        cache.countLimit = 3
        return cache
    }()
    
    fileprivate var childsToClean = Set<UIViewController>()
    
    fileprivate var latestOffsetX = 0.0                  //用于手势拖动scrollView时，判断方向
    fileprivate var guessToIndex = -1                   //用于手势拖动scrollView时，判断要去的页面
    fileprivate var lastSelectedIndex = -1               //用于记录上次选择的index
    fileprivate var firstWillAppear = true              //用于界定页面首次WillAppear。
    fileprivate var firstDidAppear = true               //用于界定页面首次DidAppear。
    fileprivate var firstDidLayoutSubViews = true       //用于界定页面首次DidLayoutsubviews。
    fileprivate var firstWillLayoutSubViews = true      //用于界定页面首次WillLayoutsubviews。
    fileprivate var isDecelerating = false              //正在减速操作
    
    fileprivate var isTapToTransition = false              //是否通过点击事件切换page
    
    fileprivate var latestContentOffsetDict: [Int: CGFloat] = [:]
    fileprivate var latestRelativeOffsetFromTabDict: [Int: CGFloat] = [:]

    //MARK: - Lift Cycles
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.memCache.delegate = self
        
        scrollView.delegate = self
        self.view.addSubview(scrollView)
        
        var addConstraints = [
            NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0,constant: contentEdgeInsets.left),
            NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0,constant: -contentEdgeInsets.right)
        ]
        if #available(iOS 11.0, *) {
            addConstraints += [
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: contentEdgeInsets.top),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -contentEdgeInsets.bottom)
            ]
        } else {
            addConstraints += [
                NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: self.topLayoutGuide, attribute: .bottom, multiplier: 1.0,constant: contentEdgeInsets.top),
                NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1.0,constant: -contentEdgeInsets.bottom)
            ]
        }
        NSLayoutConstraint.activate(addConstraints)
        
        setupScreenEdgePanGestureRecognizer()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if self.firstWillAppear {
//            self.gy_pageControllerWillShow(self.lastSelectedIndex, toIndex: self.currentPageIndex, animated: false)
//            self.firstWillAppear = false
//        }
//        currentPage?.beginAppearanceTransition(true, animated: animated)
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if self.firstDidAppear {
//            self.gy_pageControllerDidShow(self.lastSelectedIndex, toIndex: self.currentPageIndex, finished: true)
//            self.firstDidAppear = false
//        }
//        currentPage?.endAppearanceTransition()
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.firstDidLayoutSubViews {
            //Solve scrollView bug: can scroll to negative offset when pushing a UIViewController containing a UIScrollView using a UINavigationController.
            if self.navigationController?.viewControllers.last == self {
                self.scrollView.contentOffset = CGPoint.zero
                self.scrollView.contentInset = UIEdgeInsets.zero
            }
            self.firstDidLayoutSubViews = false
        }
        // Solve iOS7 crash: scrollView setContentOffset will trigger layout subviews methods. Use GCD dispatch_after to update scrollView contentOffset.
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.0 * Float(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            // Amend location of current page index
            self.scrollView.updateContentSizeIfNeeded(pageCount: self.pageCount)
            self.updateScrollViewDisplayIndexIfNeeded()
        })
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentPage?.beginAppearanceTransition(false, animated: animated)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentPage?.endAppearanceTransition()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        self.memCache.removeAllObjects()
    }
    
    deinit {
        removeScrollObservers()
        self.memCache.delegate = nil
        scrollView.delegate = nil
    }
    
    //MARK: - Update controllers & views
    @objc public func reloadPageAtIndex(_ index: Int, animated: Bool, clearCache: Bool = false) {
        lastSelectedIndex = 0
        currentPageIndex = 0
        if clearCache {
            cleanCacheToClean()
            self.memCache.removeAllObjects()
        } else {
            self.memCache.removeObject(forKey: NSNumber(value: index))
        }
        scrollView.updateContentSizeIfNeeded(pageCount: self.pageCount)
        showPageAtIndex(index, animated: animated)
    }
    
    @objc public func showPageAtIndex(_ index: Int, animated: Bool, completion: ((Int) -> Void)? = nil) {
        guard 0 <= index, index < pageCount else {
            return
        }
        
        isTapToTransition = true
        
        guard self.scrollView.frame.size.width > 0.0 && self.scrollView.contentSize.width > 0.0 else {
            // size of scroll view will be zero when page controller not load entirely (viewDidLayoutSubviews not call)
            self.lastSelectedIndex = self.currentPageIndex
            self.currentPageIndex = index
            return
        }
        
        self.setViewContorllerToVisiableAt(index: index)
        
        // Synchronize the indexs and store old select index
        let oldSelectedIndex = self.lastSelectedIndex
        self.lastSelectedIndex = self.currentPageIndex
        self.currentPageIndex = index
        
        willShow(from: lastSelectedIndex, to: currentPageIndex, animated: animated, isScrolling: false)

        currentPage?.beginAppearanceTransition(true, animated: animated)
        if currentPageIndex != lastSelectedIndex {
            controllerAtIndex(lastSelectedIndex)?.beginAppearanceTransition(false, animated: animated)
        }
        
        let scrollEndAnimation = { [weak self] in
            guard let strong = self else {
                return
            }
            
            strong.scrollView.setContentOffset(strong.scrollView.pageOffsetAt(index: strong.currentPageIndex), animated: false)
            
            strong.currentPage?.endAppearanceTransition()
            if strong.currentPageIndex != strong.lastSelectedIndex {
                strong.controllerAtIndex(strong.lastSelectedIndex)?.endAppearanceTransition()
            }
            
            strong.didShow(from: strong.lastSelectedIndex, to: strong.currentPageIndex, animated: animated, isScrolling: false)
            strong.cleanCacheToClean()
            completion?(index)
        }
        
        if animated, lastSelectedIndex != currentPageIndex,
            let lastView = controllerAtIndex(lastSelectedIndex)?.view,
            let currentView = currentPage?.view,
            let oldSelectView = controllerAtIndex(oldSelectedIndex)?.view {
            
            let pageSize = self.scrollView.frame.size
            let direction = (self.lastSelectedIndex < self.currentPageIndex) ? HUPageScrollDirection.right : HUPageScrollDirection.left
            let backgroundIndex = scrollView.pageIndex()
            var backgroundView: UIView?
            
            /*
             *  To solve the problem: when multiple animations were fired, there is an extra unuseful view appeared under the scrollview's two subviews(used to simulate animation: lastView, currentView).
             *
             *  Hide the extra view, and after the animation is finished set its hidden property false.
             */
            if let old = oldSelectView.layer.animationKeys()?.count, old > 0, let last = lastView.layer.animationKeys()?.count, last > 0 {
                let tmpView = self.controllerAtIndex(backgroundIndex)?.view
                if tmpView != currentView && tmpView != lastView {
                    backgroundView = tmpView
                    backgroundView?.isHidden = true
                }
            }
            
            // Cancel animations is not completed when multiple animations are fired
            self.scrollView.layer.removeAllAnimations()
            oldSelectView.layer.removeAllAnimations()
            lastView.layer.removeAllAnimations()
            currentView.layer.removeAllAnimations()
            
            // oldSelectView is not useful for simulating animation, move it to origin position.
            self.moveToOriginPositionIfNeed(oldSelectView, index: oldSelectedIndex)
            
            // Bring the views for simulating scroll animation to front and make them visible
            self.scrollView.bringSubview(toFront: lastView)
            self.scrollView.bringSubview(toFront: currentView)
            lastView.isHidden = false
            currentView.isHidden = false
            
            // Calculate start positions , animate to positions , end positions for simulating animation views(lastView, currentView)
            let lastViewStartOrigin = lastView.frame.origin
            let currentViewStartOrigin = CGPoint(x: lastView.frame.origin.x + (direction == .right ? pageSize.width: -pageSize.width), y:  lastView.frame.origin.y)
            
            let lastViewAnimateToOrigin = CGPoint(x: lastView.frame.origin.x + (direction == .right ? -pageSize.width: pageSize.width), y:  lastView.frame.origin.y)
            let currentViewAnimateToOrigin = lastView.frame.origin
            
            let lastViewEndOrigin = lastView.frame.origin
            let currentViewEndOrigin = currentView.frame.origin
            
            /*
             *  Simulate scroll animation
             *  Bring two views(lastView, currentView) to front and simulate scroll in neighbouring position.
             */
            lastView.frame = CGRect(origin: lastViewStartOrigin, size: pageSize)
            currentView.frame = CGRect(origin: currentViewStartOrigin, size: pageSize)
            
            UIView.animate(
                withDuration: 0.3,
                delay: 0.0,
                options: UIViewAnimationOptions(),
                animations: {
                    lastView.frame = CGRect(origin: lastViewAnimateToOrigin, size: pageSize)
                    currentView.frame = CGRect(origin: currentViewAnimateToOrigin, size: pageSize)
            },
                completion: { [weak self] (finished) in
                    lastView.frame = CGRect(origin: lastViewEndOrigin, size: pageSize)
                    currentView.frame = CGRect(origin: currentViewEndOrigin, size: pageSize)
                    backgroundView?.isHidden = false
                
                    if let strongSelf = self {
                        strongSelf.moveToOriginPositionIfNeed(currentView, index: strongSelf.currentPageIndex)
                        strongSelf.moveToOriginPositionIfNeed(lastView, index: strongSelf.lastSelectedIndex)
                    }
                    scrollEndAnimation()
            })
        } else {
            scrollEndAnimation()
        }
    }
    
    @objc fileprivate func moveToOriginPositionIfNeed(_ view: UIView?, index: Int) {
        guard 0 <= index, index < pageCount else {
            return
        }
        
        guard let destView = view else {
            pageLog("moveToOriginPositionIfNeed view nil")
            return
        }
        
        let originPosition = scrollView.pageOffsetAt(index: index)
        if destView.frame.origin.x != originPosition.x {
            var newFrame = destView.frame
            newFrame.origin = originPosition
            destView.frame = newFrame
        }
    }
    
    @objc fileprivate func setViewContorllerToVisiableAt(index: Int) {
        guard 0 <= index, index < pageCount else { return }
        guard let viewC = memCache.object(forKey: NSNumber(value: index)) ?? controllerAtIndex(index) else { return }
        
        let childViewFrame = scrollView.pageFrameAt(index: index)
        viewC.view.frame = childViewFrame
        
        let isContained = childViewControllers.contains(viewC)
        if isContained == false {
            viewC.willMove(toParentViewController: self)
            addChildViewController(viewC)
            setScrollObserverAt(index: index, controller: viewC)
        }
        if scrollView.subviews.contains(viewC.view) == false {
            scrollView.addSubview(viewC.view)
        }
        setScrollViewOffsetYAt(index: index, controller: viewC)
        if isContained == false {
            viewC.didMove(toParentViewController: self)
        }
        self.memCache.setObject(viewC, forKey: NSNumber(value: index))
    }
    
    fileprivate func updateScrollViewDisplayIndexIfNeeded() {
        if self.scrollView.frame.size.width > 0.0 {
            self.setViewContorllerToVisiableAt(index: self.currentPageIndex)
            let newOffset = scrollView.pageOffsetAt(index: self.currentPageIndex)
            if newOffset.x != self.scrollView.contentOffset.x || newOffset.y != self.scrollView.contentOffset.y {
                self.scrollView.contentOffset = newOffset
            }
            currentPage?.view.frame = self.scrollView.pageFrameAt(index: self.currentPageIndex)
        }
    }
    
    //MARK: - Helper methods
    @objc fileprivate func controllerAtIndex(_ index: NSInteger) -> UIViewController? {
        if 0 <= index, index < pageCount {
            return self.dataSource?.pageController(self, controllerAtIndex: index)
        } else {
            return nil
        }
    }
    
    @objc fileprivate func cleanCacheToClean() {
        if let currentPage = currentPage, self.childsToClean.contains(currentPage) {
            if let removeIndex = self.childsToClean.index(of: currentPage) {
                self.childsToClean.remove(at: removeIndex)
                self.memCache.setObject(currentPage, forKey: NSNumber(value: self.currentPageIndex))
            }
        }
        
        for vc in self.childsToClean {
            removeScrollObserver(controller: vc)
            vc.removeFromPageController()
        }
        self.childsToClean.removeAll()
    }
    
    //MARK: - NSCacheDelegate
    public func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if (obj as AnyObject).isKind(of: UIViewController.self) {
            let vc = obj as! UIViewController
            //            pageLog("-1- to remove from cache \((vc as! TestChildViewController).pageIndex)")
            if self.childViewControllers.contains(vc) {
                //                pageLog("============================tracking \(scrollView.tracking)  dragging \(scrollView.dragging) decelerating \(scrollView.decelerating)")
                
                let AddCacheToCleanIfNeed = { (midIndex:Int) -> Void in
                    //Modify memCache through showPageAtIndex.
                    var leftIndex = midIndex - 1;
                    var rightIndex = midIndex + 1;
                    if leftIndex < 0 {
                        leftIndex = midIndex
                    }
                    if rightIndex > self.pageCount - 1 {
                        rightIndex = midIndex
                    }
                    
                    let leftNeighbour = self.dataSource!.pageController(self, controllerAtIndex: leftIndex)
                    let midPage = self.dataSource!.pageController(self, controllerAtIndex: midIndex)
                    let rightNeighbour = self.dataSource!.pageController(self, controllerAtIndex: rightIndex)
                    
                    if leftNeighbour == vc || rightNeighbour == vc || midPage == vc
                    {
                        self.childsToClean.insert(vc)
                    }
                }
                
                // When scrollView's dragging, tracking and decelerating are all false.At least it means the cache eviction is not triggered by continuous interaction page changing.
                if self.scrollView.isDragging == false &&
                    self.scrollView.isTracking == false &&
                    self.scrollView.isDecelerating == false
                {
                    let lastPage = self.controllerAtIndex(self.lastSelectedIndex)
                    let currentPage = self.currentPage
                    if lastPage == vc || currentPage == vc {
                        self.childsToClean.insert(vc)
                    }
                    //                    pageLog("self.currentPageIndex  \(self.currentPageIndex)")
                } else if self.scrollView.isDragging == true
                {
                    AddCacheToCleanIfNeed(self.guessToIndex)
                    //                    pageLog("self.guessToIndex  \(self.guessToIndex)")
                }
                
                if self.childsToClean.count > 0 {
                    return
                }
                
                removeScrollObserver(controller: vc)
                vc.removeFromPageController()
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.frame.width > 0 else { return }
        
//        pageLog("====  DidScroll dragging:  \(scrollView.isDragging)  decelorating: \(scrollView.isDecelerating)  offset:\(scrollView.contentOffset)")
        guard scrollView.isDragging && scrollView == self.scrollView else { return }
        
        let offset = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let lastGuessIndex = self.guessToIndex < 0 ? self.currentPageIndex : self.guessToIndex
        var currentIndex = -1
        var progress = 0.0
        
        if latestOffsetX < Double(offset) {
            guessToIndex = Int(ceil((offset)/width))
            currentIndex = Int(floor((offset)/width))
            progress = Double(offset / width) - Double(currentIndex)
        } else if (latestOffsetX > Double(offset)) {
            guessToIndex = Int(floor((offset)/width))
            currentIndex = Int(ceil((offset)/width))
            progress = Double(currentIndex) - Double(offset / width)
        } else {}
        
        // 1.Decelerating is false when first drag during discontinuous interaction.
        // 2.Decelerating is true when drag during continuous interaction.
        if (guessToIndex != self.currentPageIndex && self.scrollView.isDecelerating == false) || self.scrollView.isDecelerating == true {
            if lastGuessIndex != self.guessToIndex && self.guessToIndex >= 0 && self.guessToIndex < pageCount {
                pageLog("====1 decelorating: \(scrollView.isDecelerating)  offset:\(scrollView.contentOffset)")
                pageLog("====2 guessToIndex:\(self.guessToIndex) currentPageIndex:\(currentPageIndex) lastGuessIndex:\(lastGuessIndex)")
                
                willShow(from: currentPageIndex, to: guessToIndex, animated: true, isScrolling: true)
                
                self.setViewContorllerToVisiableAt(index: self.guessToIndex)
                self.controllerAtIndex(self.guessToIndex)?.beginAppearanceTransition(true, animated: true)
                pageLog("scrollViewDidScroll beginAppearanceTransition  self.guessToIndex  \(self.guessToIndex)")
                /**
                 *  Solve problem: When scroll with interaction, scroll page from one direction to the other for more than one time, the beginAppearanceTransition() method will invoke more than once but only one time endAppearanceTransition() invoked, so that the life cycle methods not correct.
                 *  When lastGuessIndex = self.currentPageIndex is the first time which need to invoke beginAppearanceTransition().
                 */
                if lastGuessIndex == self.currentPageIndex {
                    currentPage?.beginAppearanceTransition(false, animated: true)
                    pageLog("scrollViewDidScroll beginAppearanceTransition  self.currentPageIndex \(self.currentPageIndex)")
                }
                
                if lastGuessIndex != self.currentPageIndex &&
                    lastGuessIndex >= 0 &&
                    lastGuessIndex < pageCount{
                    self.controllerAtIndex(lastGuessIndex)?.beginAppearanceTransition(false, animated: true)
                    pageLog("scrollViewDidScroll beginAppearanceTransition  lastGuessIndex \(lastGuessIndex)")
                    self.controllerAtIndex(lastGuessIndex)?.endAppearanceTransition()
                    pageLog("scrollViewDidScroll endAppearanceTransition  lastGuessIndex \(lastGuessIndex)")
                }
            }
        }
        
        if !isTapToTransition {
            if progress != 0.0 && currentIndex != -1 && 0 <= guessToIndex && guessToIndex < self.pageCount {
                delegate?.pageController?(self, didLeaveFrom: currentIndex, toIndex: guessToIndex, progress: progress)
            }
        }
    }
    
    // called on start of dragging (may require some time and or distance to move)
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        pageLog("====  WillBeginDragging:  \(scrollView.isDragging)  decelorating: \(scrollView.isDecelerating)  offset:\(scrollView.contentOffset)")
        isTapToTransition = false
        if scrollView.isDecelerating == false {
            self.latestOffsetX = Double(scrollView.contentOffset.x)
            self.guessToIndex = self.currentPageIndex
        }
    }
    
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        pageLog("====  WillEndDragging: \(velocity)  targetContentOffset: \(targetContentOffset.pointee)  dragging:  \(scrollView.isDragging)  decelorating: \(scrollView.isDecelerating)  offset:\(scrollView.contentOffset)  velocity  \(velocity)")
        
        if scrollView.isDecelerating == true {
            // Update latestOffsetX for calculating new guessIndex to add controller.
            let offset = scrollView.contentOffset.x
            let width = scrollView.frame.width
            if velocity.x > 0 { // to right page
                self.latestOffsetX = Double(floor(offset/width)) * Double(width)
            } else if velocity.x < 0 {// to left page
                self.latestOffsetX = Double(ceil(offset/width)) * Double(width)
            }
        }
        
        //pageLog("will end tragging  tracking \(scrollView.isTracking)  dragging \(scrollView.isDragging) decelerating \(scrollView.isDecelerating)")
        
        // 如果松手时位置，刚好不需要decelerating。则主动调用刷新page。
        let offset = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.frame.size.width
        if (Int(offset * 100) % Int(scrollViewWidth * 100)) == 0 {
            pageLog("updatePageViewAfterTragging--1")
            self.updatePageViewAfterTragging(scrollView: scrollView)
        }
    }
    
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        pageLog("====  DidEndDragging: \(decelerate)  dragging:  \(scrollView.isDragging)  decelorating: \(scrollView.isDecelerating)  offset:\(scrollView.contentOffset) currentIndex")
        //快速滚动的时候第一页和最后一页(scroll too fast will not call 'scrollViewDidEndDecelerating')
        let currentIndex = Int(floor(scrollView.contentOffset.x / scrollView.frame.width))

        if scrollView.contentOffset.x == 0 || scrollView.contentOffset.x == scrollView.contentSize.width - scrollView.bounds.width {
            if self.currentPageIndex != currentIndex {
                pageLog("updatePageViewAfterTragging--")
                self.updatePageViewAfterTragging(scrollView: scrollView)
            }
        }
    }
    
    // called on finger up as we are moving
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        pageLog("====  BeginDecelerating dragging:  \(scrollView.isDragging)  decelorating: \(scrollView.isDecelerating)  offset:\(scrollView.contentOffset)")
        self.isDecelerating = true
    }
    
    // called when scroll view grinds to a halt
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageLog("====  DidEndDecelerating  dragging:  \(scrollView.isDragging)  decelorating: \(scrollView.isDecelerating)  offset:\(scrollView.contentOffset)")
        self.updatePageViewAfterTragging(scrollView: scrollView)
    }
    
    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageLog("====  DidEndScrollingAnimation: dragging:  \(scrollView.isDragging)  decelorating: \(scrollView.isDecelerating)  offset:\(scrollView.contentOffset)")
    }
    
    override open var shouldAutomaticallyForwardAppearanceMethods : Bool {
        return false
    }
    
    //MARK: - Update page after tragging
    func updatePageViewAfterTragging(scrollView: UIScrollView) {
        pageLog("==== guessToIndex:\(self.guessToIndex) currentPageIndex:\(currentPageIndex)")

        let newIndex = scrollView.pageIndex()
        let oldIndex = currentPageIndex
        self.currentPageIndex = newIndex
        
        setViewContorllerToVisiableAt(index: newIndex)
        
        if newIndex != guessToIndex {
            self.controllerAtIndex(guessToIndex)?.endAppearanceTransition()
            pageLog("scrollViewDidScroll endAppearanceTransition  self.guessToIndex  \(self.guessToIndex)")
            self.controllerAtIndex(newIndex)?.beginAppearanceTransition(true, animated: true)
        }
        
        if newIndex == oldIndex {//最终确定的位置与开始位置相同时，需要重新显示开始位置的视图，以及消失最近一次猜测的位置的视图。
            if self.guessToIndex >= 0 && self.guessToIndex < self.pageCount {
                self.controllerAtIndex(oldIndex)?.beginAppearanceTransition(true, animated: true)
                self.controllerAtIndex(oldIndex)?.endAppearanceTransition()
                self.controllerAtIndex(self.guessToIndex)?.beginAppearanceTransition(false, animated: true)
                self.controllerAtIndex(self.guessToIndex)?.endAppearanceTransition()
            }
        } else {
            self.controllerAtIndex(newIndex)?.endAppearanceTransition()
            self.controllerAtIndex(oldIndex)?.endAppearanceTransition()
        }
        
        //归位，用于计算比较
        self.latestOffsetX = Double(scrollView.contentOffset.x)
        self.guessToIndex = self.currentPageIndex
        
        didShow(from: oldIndex, to: newIndex, animated: true, isScrolling: true)

        self.isDecelerating = false
        
        self.cleanCacheToClean()
    }
    
    //MARK: - Method to be override in subclass
    func willShow(from: Int, to: Int, animated: Bool, isScrolling: Bool) {
        pageLog("from \(from) to \(to)")
        if from != -1, 0 <= to, to < pageCount {
            delegate?.pageController?(self, willLeaveFrom: from, toIndex: to, animated: animated, isScrolling: isScrolling)
        }
    }
    
    func didShow(from: Int, to: Int, animated: Bool, isScrolling: Bool) {
        pageLog("from \(from) to \(to)")
        if from != -1, 0 <= to, to < pageCount {
            delegate?.pageController?(self, didLeaveFrom: from, toIndex: to, animated: animated, isScrolling: isScrolling)
        }
    }
    
    //MARK: - Observer vertical scroll offset
    func setScrollObserverAt(index: Int, controller: UIViewController) {
        guard let subController = controller as? HUPageSubController, let scrollV = subController.mainScrollView?() else { return }
        scrollV.tag = index + 1
        scrollV.addObserver(self, forKeyPath: "contentOffset", options: [.new, .initial], context: nil)
        
        guard let top = delegate?.pageController?(self, maxOffsetFromTopAt: index) else { return }
        scrollV.contentInset = UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
        scrollV.scrollIndicatorInsets = scrollV.contentInset
    }
    
    func setScrollViewOffsetYAt(index: Int, controller: UIViewController) {
        debugLog("----- \(index) \(currentPageIndex) \(lastSelectedIndex)")
        debugLog(latestContentOffsetDict)
        debugLog(latestRelativeOffsetFromTabDict)
        guard
            let maxOffsetFromTop = delegate?.pageController?(self, maxOffsetFromTopAt: currentPageIndex),
            let minOffsetFromTop = delegate?.pageController?(self, minOffsetFromTopAt: currentPageIndex),
            let currentOffsetY = delegate?.pageController?(self, currentOffsetFromTopAt: currentPageIndex) else {
                return
        }
        
        var willOffsetY: CGFloat = 0
        let lastRelativeOffsetFromTab = latestRelativeOffsetFromTabDict[index] ?? 0
        debugLog("\(currentOffsetY) \(lastRelativeOffsetFromTab)")
        if currentOffsetY >= maxOffsetFromTop {
            willOffsetY = -maxOffsetFromTop
            latestRelativeOffsetFromTabDict[index] = nil
        } else if currentOffsetY <= minOffsetFromTop {
            willOffsetY = -minOffsetFromTop + lastRelativeOffsetFromTab
        } else {
            willOffsetY = -currentOffsetY
            latestRelativeOffsetFromTabDict[index] = nil
        }
        latestContentOffsetDict[index] = willOffsetY

        guard let subController = controller as? HUPageSubController, let scrollV = subController.mainScrollView?() else { return }
        scrollV.tag = index + 1
        controller.view.layoutIfNeeded()
        scrollV.contentOffset = CGPoint(x: 0, y: willOffsetY)
        debugLog("\(index) \(scrollV.contentOffset)")
    }
    
    func removeScrollObserver(controller: UIViewController) {
        if let subController = controller as? HUPageSubController, let scrollV = subController.mainScrollView?() {
            scrollV.removeObserver(self, forKeyPath: "contentOffset")
        }
    }

    func removeScrollObservers() {
        for controller in self.childViewControllers {
            if let subController = controller as? HUPageSubController, let scrollV = subController.mainScrollView?() {
                scrollV.removeObserver(self, forKeyPath: "contentOffset")
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset", let hScrollView = object as? UIScrollView {
            guard hScrollView.tag == currentPageIndex + 1 else { return }
            guard hScrollView.contentSize.height >= hScrollView.frame.height else { return }
            guard let latestOffset = latestContentOffsetDict[currentPageIndex], fabs(latestOffset - hScrollView.contentOffset.y) >= 0.1 else { return }
            
            delegate?.pageController?(self, scroll: hScrollView.contentOffset.y, at: currentPageIndex)
            latestContentOffsetDict[currentPageIndex] = hScrollView.contentOffset.y
            
            guard let minOffsetFromTop = delegate?.pageController?(self, minOffsetFromTopAt: currentPageIndex) else { return }

            if hScrollView.contentOffset.y > -minOffsetFromTop {
                latestRelativeOffsetFromTabDict[currentPageIndex] = hScrollView.contentOffset.y - (-minOffsetFromTop)
            } else {
                latestRelativeOffsetFromTabDict[currentPageIndex] = 0
            }
            debugLog("==== \(currentPageIndex) \(hScrollView.tag) \(latestRelativeOffsetFromTabDict[currentPageIndex] ?? 0)")
        }
    }
    
    //MARK: - Update page after tragging
    func setupScreenEdgePanGestureRecognizer() {
        if let screenGesture = delegate?.screenEdgePanGestureRecognizerForPageController?(self) {
            scrollView.panGestureRecognizer.require(toFail: screenGesture)
        } else if let screenGesture = screenPanGesture {
            scrollView.panGestureRecognizer.require(toFail: screenGesture)
        }
    }
    
    private var screenPanGesture: UIScreenEdgePanGestureRecognizer? {
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
