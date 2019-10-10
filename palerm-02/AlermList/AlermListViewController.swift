//
//  AlermList.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/10/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit

final class AlermListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var presenter: AlermListPresenterProtocol!
    func inject(presenter: AlermListPresenterProtocol) {
        self.presenter = presenter
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        presenter.loadAlermList()
    }

    func setup() {
        setConstraintsForTableView()
        self.view.backgroundColor = PalermColor.Dark200.UIColor
        tableView.backgroundColor = PalermColor.Dark200.UIColor
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
    }
    
    private func setConstraintsForTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
}

