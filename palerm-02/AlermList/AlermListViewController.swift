//
//  AlermList.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/10/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class AlermListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
    private var presenter: AlermListPresenterInput!
    func inject(presenter: AlermListPresenterInput) {
        self.presenter = presenter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setup()
        presenter.loadAlermList()
//        setTestView()
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
    
    private func setTestView() {
        let button = UIButton(frame: CGRect(x: 50, y: 50, width: 100, height: 50))
        button.setTitle("ボタンだよ", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.backgroundColor = .white
        self.view.addSubview(button)
    }
}

let ALERM_CARD_CELL_TOP_PADDING = 5
let ALERM_CARD_CELL_BOTTOM_PADDING = 5
let ALERM_CARD_CELL_TOP_PADDING_WHEN_FIRST_CELL = 16

extension AlermListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.alermCardList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let index = (indexPath as NSIndexPath).row
        let alermCard = self.presenter.alermCardList[index]

        // 設定されている時間が一つだけのとき
        guard alermCard.head != nil else {
            var padding: CGFloat = CGFloat(ALERM_CARD_CELL_TOP_PADDING + ALERM_CARD_CELL_BOTTOM_PADDING)
            if index == 0 {
                padding = CGFloat(ALERM_CARD_CELL_TOP_PADDING_WHEN_FIRST_CELL + ALERM_CARD_CELL_BOTTOM_PADDING)
            }
            return (alermCard.selfView.frame.height)+padding
        }

        var height: CGFloat = alermCard.head!.selfView.frame.height
        if let foot = alermCard.foot?.selfView {
            height += foot.frame.height
        }

        var expandHeight: CGFloat = 0
        if alermCard.alermTimeCellList?.height != nil && alermCard.isExpand {
            expandHeight += alermCard.alermTimeCellList!.height!
        }
        
        var padding: CGFloat = CGFloat(ALERM_CARD_CELL_TOP_PADDING + ALERM_CARD_CELL_BOTTOM_PADDING)
        if index == 0 {
            padding = CGFloat(ALERM_CARD_CELL_TOP_PADDING_WHEN_FIRST_CELL + ALERM_CARD_CELL_BOTTOM_PADDING)
        }
        height += padding

        height += expandHeight
        return height
    }
}

extension AlermListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        let index = (indexPath as NSIndexPath).row
        cell.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0)
        cell.selectionStyle = .none
        cell.clipsToBounds = false
        cell.layer.zPosition = CGFloat(1 * index)

        let alermCard = self.presenter.alermCardList[index].selfView
        var yPosition: CGFloat = CGFloat(ALERM_CARD_CELL_TOP_PADDING)
        if index == 0 {
            yPosition = CGFloat(ALERM_CARD_CELL_TOP_PADDING_WHEN_FIRST_CELL)
        }
        alermCard.frame.origin = CGPoint(x: 0, y: yPosition)
        alermCard.center.x = self.view.center.x

        cell.addSubview(alermCard)
        var topMargin: CGFloat = CGFloat(ALERM_CARD_CELL_TOP_PADDING)
        if index == 0 {
            topMargin = CGFloat(ALERM_CARD_CELL_TOP_PADDING_WHEN_FIRST_CELL)
        }
        let topAnchor = alermCard.topAnchor.constraint(equalTo: cell.topAnchor, constant: topMargin)
        topAnchor.isActive = true
        self.presenter.alermCardList[index].setTopAnchor(topAnchor)
        alermCard.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16).isActive = true
        alermCard.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16).isActive = true
        cell.layoutIfNeeded()
        return cell
    }
}

extension AlermListViewController: AlermListPresenterOutput {
    func resizeAlermCard() {
        print("--- resize alerm card")
    }
}
