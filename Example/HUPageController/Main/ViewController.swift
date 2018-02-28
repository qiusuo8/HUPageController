//
//  ViewController.swift
//  HUPageController_Example
//
//  Created by Huizz on 2018/2/28.
//  Copyright © 2018年 Qiusuo8. All rights reserved.
//

import UIKit

class MenuCell: UICollectionViewCell {
    
    lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 16)
        view.textColor = UIColor.black
        view.textAlignment = .left
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.text = ""
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white
        
        contentView.addSubview(titleLabel)
        
        let views: [String: Any] = [
            "titleLabel": titleLabel
        ]
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[titleLabel]-16-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[titleLabel]-8-|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class ViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 7
        let view = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 200), collectionViewLayout: layout)
        view.scrollsToTop = true
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = UIColor.lightGray
        view.alwaysBounceVertical = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    fileprivate var dataProvider = MenuDataProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(collectionView)
        var addConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[collectionView]-0-|", options: [], metrics: nil, views: ["collectionView": collectionView])
        addConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[collectionView]-0-|", options: [], metrics: nil, views: ["collectionView": collectionView])
        NSLayoutConstraint.activate(addConstraints)
        
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: MenuCell.qsReuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        dataProvider.sampleData()
        collectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    @objc(numberOfSectionsInCollectionView:) func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataProvider.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionData = dataProvider.sections[section]
        return sectionData.titles.count
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionData = dataProvider.sections[indexPath.section]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCell.qsReuseIdentifier, for: indexPath) as? MenuCell
        cell?.titleLabel.text = sectionData.titles[indexPath.row]
        cell?.accessibilityLabel = sectionData.titles[indexPath.row]
        return cell!
    }
}

//MARK: UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {
    @objc(collectionView:layout:sizeForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (UIScreen.main.bounds.width - 8) / 2.0, height: 60)
    }
    
    @objc(collectionView:layout:insetForSectionAtIndex:) func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    @objc(collectionView:didSelectItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let controller = DemoTabViewController()
            self.navigationController?.pushViewController(controller, animated: true)
        case 1:
            let controller = DemoCoverController()
            self.navigationController?.pushViewController(controller, animated: true)
        default:
            break
        }
    }
}
