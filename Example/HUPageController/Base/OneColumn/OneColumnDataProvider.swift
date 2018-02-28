//
//  OneColumnDataProvider.swift
//  HUPageController_Example
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

class OneColumnRowViewModel {
    var image: UIImage = #imageLiteral(resourceName: "taiouyu")
    
    init() {
    }
}

class OneColumnSectionViewModel {
    func identifierForItemAt(index: Int) -> String {
        return OneColumnCell.qsReuseIdentifier
    }
    var rows: [OneColumnRowViewModel] {
        return _subViewModels
    }
    var title: String {
        return _title
    }
    var targetUrl: String {
        return ""
    }
    var referenceSizeForHeader: CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: 24 + 8)
    }
    func sizeForItemAt(index: Int) -> CGSize {
        let spaceWidth = UIScreen.main.bounds.size.width - insetForSection.left - insetForSection.right
        let height = floor((spaceWidth - 3 * 8) / 4)
        let size = CGSize(width: spaceWidth, height: height)
        return size
    }
    var insetForSection: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    fileprivate var _subViewModels: [OneColumnRowViewModel] = []
    private var _title: String = "Basic"
    
    init(title: String, subModels: [OneColumnRowViewModel]) {
        _title = title
        _subViewModels = subModels
    }
}

class OneColumnDataProvider {
    var category: String = ""
    var sections: [OneColumnSectionViewModel] = []
    
    init() {
        var sectionModels: [OneColumnSectionViewModel] = []
        
        let packages = ["Basic", "Middle", "High", "Super"]
        for package in packages {
            var rowModels: [OneColumnRowViewModel] = []
            
            for _ in 0..<15 {
                let rowModel = OneColumnRowViewModel()
                rowModels.append(rowModel)
            }
            if rowModels.count > 0 {
                let sectionModel = OneColumnSectionViewModel(title: package, subModels: rowModels)
                sectionModels.append(sectionModel)
            }
        }
        
        self.sections = sectionModels
    }
}


