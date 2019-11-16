//
//  AlermSettingViewController.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/11/17.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit

class AlermSettingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    private func setup() {
        self.view.backgroundColor = PalermColor.Dark200.UIColor
        self.setNavBar()
    }
    
    private func setNavBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        navBar.barStyle = .black

        let navItem = UINavigationItem()
        let doneItem = UIBarButtonItem(title: "完了", style: .done, target: nil, action: nil)
        let cancelItem = UIBarButtonItem(title: "キャンセル", style: .plain, target: nil, action: nil)
        navItem.rightBarButtonItem = doneItem
        navItem.leftBarButtonItem = cancelItem
        navBar.setItems([navItem], animated: false)
        
        self.view.addSubview(navBar)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        navBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        navBar.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
        navBar.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        
    }
}
