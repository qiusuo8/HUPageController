//
//  DemoTabDataProvider.swift
//  HUPageController_Example
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

class DemoTabDataProvider {
    var multiColumnTitles: [String] = []
    var multiColumnControllers: [ MultiColumnViewController] = []
    
    var oneColumnTitles: [String] = []
    var oneColumnControllers: [OneColumnViewController] = []

    var successHandler: (() -> Void)?
    var failHandler: ((String) -> Void)?
    
    init() {
    }
    
    deinit {
    }
    
    func fetchMultiColumns() {
        self.sampleDataForMultiColumn()
        self.successHandler?()
    }
    
    func fetchOneColumns() {
        self.sampleDataForOneColumn()
        self.successHandler?()
    }
    
    private func sampleDataForMultiColumn() {
        multiColumnControllers = []
        multiColumnTitles = []
        let categories = ["ALL", "Guide", "Movie&Series", "Sports", "Kids", "Music", "Religion", "Times&Months", "Others"]
        for category in categories {
            let controller =  MultiColumnViewController()
            let dataProvider = MultiColumnDataProvider()
            dataProvider.category = category
            controller.dataProvider = dataProvider
            multiColumnControllers.append(controller)
            multiColumnTitles.append(category)
        }
    }
    
    private func sampleDataForOneColumn() {
        oneColumnControllers = []
        oneColumnTitles = []
        let categories = ["ALL", "Guide", "Movie&Series", "Sports", "Kids", "Music", "Religion", "Times&Months", "Others", "One Two"]
        for category in categories {
            let controller =  OneColumnViewController()
            oneColumnControllers.append(controller)
            oneColumnTitles.append(category)
        }
    }
}
