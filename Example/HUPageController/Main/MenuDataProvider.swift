//
//  MenuDataProvider.swift
//  HUPageController_Example
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import Foundation

class MenuSection {
    var titles: [String] = []
}

class MenuDataProvider {
    
    var sections: [MenuSection] = []
    
    init() {
    }
    
    func sampleData() {
        sections = []
        
        let section0 = MenuSection()
        section0.titles = ["Page Examples", "Cover Examples"]
        sections.append(section0)
        
        let section1 = MenuSection()
        section1.titles = ["Tab Examples"]
        sections.append(section1)
    }
}
