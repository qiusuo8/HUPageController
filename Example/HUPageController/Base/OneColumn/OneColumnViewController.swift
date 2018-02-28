//
//  OneColumnViewController.swift
//  HUPageController_Example
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import HUPageController

class  OneColumnViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    fileprivate lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.scrollDirection = .vertical
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 100), collectionViewLayout: self.collectionLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.scrollsToTop = false
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    var dataProvider: OneColumnDataProvider = OneColumnDataProvider() {
        didSet {
            collectionView.reloadData()
        }
    }
    var pageIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(collectionView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: UInt(0)), metrics: nil, views: ["collectionView": collectionView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options: NSLayoutFormatOptions(rawValue: UInt(0)), metrics: nil, views: ["collectionView": collectionView]))
        
        collectionView.register(OneColumnCell.self, forCellWithReuseIdentifier: OneColumnCell.qsReuseIdentifier)
        collectionView.register(OneColumnHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: OneColumnHeaderView.qsReuseIdentifier)
        collectionView.reloadData()
    }
}

// MARK: UICollectionViewDataSource
extension  OneColumnViewController {
    @objc(numberOfSectionsInCollectionView:) func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataProvider.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionModel = dataProvider.sections[section]
        return sectionModel.rows.count
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionModel = dataProvider.sections[indexPath.section]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: sectionModel.identifierForItemAt(index: indexPath.row), for: indexPath) as? OneColumnCell
        cell?.viewModel = sectionModel.rows[indexPath.row]
        return cell!
    }
    
    @objc(collectionView:viewForSupplementaryElementOfKind:atIndexPath:) func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: OneColumnHeaderView.qsReuseIdentifier, for: indexPath) as! OneColumnHeaderView
        let sectionModel = dataProvider.sections[indexPath.section]
        header.titleLabel.text = sectionModel.title
        return header
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension  OneColumnViewController {
    @objc(collectionView:layout:sizeForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionModel = dataProvider.sections[indexPath.section]
        return sectionModel.sizeForItemAt(index: indexPath.row)
    }
    
    @objc(collectionView:layout:insetForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionModel = dataProvider.sections[section]
        return sectionModel.insetForSection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let sectionModel = dataProvider.sections[section]
        return sectionModel.referenceSizeForHeader
    }
}

//MARK: UICollectionViewDelegate
extension  OneColumnViewController {
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}
