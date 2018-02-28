//
//  UIScrollView+HUPageController.swift
//  HUPageController
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

func pageLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

func debugLog<T>(_ message: T, file: String = #file, method: String = #function, line: Int = #line) {
    #if DEBUG
        print("\((file as NSString).lastPathComponent)[\(line)], \(method): \(message)")
    #endif
}

extension UIScrollView {
    func pageIndex() -> Int {
        guard self.frame.width > 0 else {
            return 0
        }
        guard self.contentOffset.x > 0 else {
            return 0
        }
        return Int(self.contentOffset.x / self.frame.width)
    }
    
    func pageOffsetAt(index: Int) -> CGPoint {
        let width = self.frame.width
        let maxWidth = self.contentSize.width
        if width <= 0 || maxWidth - width <= 0 {
            return CGPoint(x: 0, y: 0)
        }
        
        var offsetX: CGFloat = CGFloat(index) * width
        offsetX = CGFloat.maximum(0, offsetX)
        offsetX = CGFloat.minimum(maxWidth - width, offsetX)
        return CGPoint(x: offsetX, y: 0)
    }
    
    func pageFrameAt(index: Int) -> CGRect {
        let offsetX: CGFloat = CGFloat(index) * self.frame.size.width
        return CGRect(x: offsetX, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    // Do not use it in viewDidLayoutSubviews on ios 7 device.
    func updateContentSizeIfNeeded(pageCount: Int) {
        if self.frame.size.width > 0.0 {
            let width = CGFloat(pageCount) * self.frame.width
            let height = self.frame.height
            let oldContentSize = self.contentSize
            if width != oldContentSize.width || height != oldContentSize.height {
                self.contentSize = CGSize(width: width, height: height)
            }
        }
    }
}

extension UIViewController {
    func removeFromPageController() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
        didMove(toParentViewController: nil)
    }
}

