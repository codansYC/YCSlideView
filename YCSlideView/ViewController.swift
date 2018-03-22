//
//  ViewController.swift
//  YCSlideView
//
//  Created by yuanchao on 2018/3/22.
//  Copyright © 2018年 yuanchao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let slideView = SlideView.init(direction: .left)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(slideView)
        let leftItem = UIBarButtonItem.init(title: "菜单", style: .plain, target: slideView, action: #selector(slideView.toggleShowState))
        navigationItem.leftBarButtonItem = leftItem
    }
    


}


