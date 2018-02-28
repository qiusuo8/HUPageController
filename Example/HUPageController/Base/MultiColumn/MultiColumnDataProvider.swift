//
//  MultiColumnDataProvider.swift
//  HUPageController_Example
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

class MultiColumnRowViewModel {
    var image: UIImage = #imageLiteral(resourceName: "taiouyu")
    
    init() {
    }
}

class MultiColumnSectionViewModel {
    func identifierForItemAt(index: Int) -> String {
        return MultiColumnCell.qsReuseIdentifier
    }
    var rows: [MultiColumnRowViewModel] {
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
        var spaceWidth = UIScreen.main.bounds.size.width - insetForSection.left - insetForSection.right
        spaceWidth = floor((spaceWidth - 3 * 8) / 4)
        let size = CGSize(width: spaceWidth, height: spaceWidth)
        return size
    }
    var insetForSection: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    fileprivate var _subViewModels: [MultiColumnRowViewModel] = []
    private var _title: String = "Basic"
    
    init(title: String, subModels: [MultiColumnRowViewModel]) {
        _title = title
        _subViewModels = subModels
    }
}

class MultiColumnDataProvider {
    var category: String = ""
    var sections: [MultiColumnSectionViewModel] = []
    
    init() {
        var sectionModels: [MultiColumnSectionViewModel] = []
        
        let packages = ["Basic", "Middle", "High", "Super"]
        for package in packages {
            var rowModels: [MultiColumnRowViewModel] = []
            
            for _ in 0..<15 {
                let rowModel = MultiColumnRowViewModel()
                rowModels.append(rowModel)
            }
            if rowModels.count > 0 {
                let sectionModel = MultiColumnSectionViewModel(title: package, subModels: rowModels)
                sectionModels.append(sectionModel)
            }
        }
        
        self.sections = sectionModels
    }
}


