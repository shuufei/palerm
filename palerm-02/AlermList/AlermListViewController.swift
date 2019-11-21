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
    
    private var addButton: AddButton? = nil
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
    }

    func setup() {
        self.setConstraintsForTableView()
        self.setAddPalermButton()
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
    
    private func setAddPalermButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "add"), for: .normal)
        button.backgroundColor = PalermColor.Dark100.UIColor
        button.layer.masksToBounds = false
        button.layer.cornerRadius = CGFloat(button.frame.width / 2)
        button.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 15
        button.layer.cornerRadius = 30
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.navigateAlermSetting(_:)))
        gesture.minimumPressDuration = 0
        button.addGestureRecognizer(gesture)
        
        self.view.addSubview(button)
        
        button.layer.zPosition = 100
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.trailingAnchor.constraint(
            equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -24
        ).isActive = true
        
        let bottomAnchorInit: CGFloat = -32
        let bottomAnchor = button.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: bottomAnchorInit)
        bottomAnchor.isActive = true
        self.addButton = AddButton(selfView: button, bottomAnchor: bottomAnchor, bottomAnchorInit: bottomAnchorInit)
    }
    
    @objc func navigateAlermSetting(_ sender: UILongPressGestureRecognizer) {
        guard (self.addButton?.bottomAnchor != nil), (self.addButton?.bottomAnchorInit != nil) else { return }
        let move: CGFloat = 3
        switch sender.state {
        case .began:
            self.addButton!.bottomAnchor!.constant += move
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        case .ended:
            self.addButton!.bottomAnchor?.constant = self.addButton!.bottomAnchorInit!
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
            // ここの責務じゃない
            let alermSettingViewContoller = AlermSettingViewController()
            alermSettingViewContoller.alermTimeList = []
            self.presentToSetting(viewController: alermSettingViewContoller)
        default:
            return
        }
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
    func resizeAlermCard(alermCard: AlermCard) {
        guard
            alermCard.alermTimeCellList != nil,
            alermCard.alermTimeCellList?.height != nil,
            alermCard.alermTimeCellList?.heightConstraints != nil,
            alermCard.foot != nil,
            alermCard.foot?.pullIcon != nil
        else { return }
        
        if !alermCard.isExpand {
            self.openAlermTimeCellList(alermCard: alermCard)
        } else {
            self.closeAlermTimeCellList(alermCard: alermCard)
        }
    }
    
    func openAlermTimeCellList(alermCard: AlermCard) {
        self.tableView.beginUpdates()
        alermCard.isExpand = true
        self.tableView.endUpdates()
        
        alermCard.alermTimeCellList!.heightConstraints!.constant = alermCard.alermTimeCellList!.height!
        alermCard.alermTimeCellList!.selfView.alpha = 1
        alermCard.foot!.pullIcon!.transform = CGAffineTransform(rotationAngle: CGFloat(180 * (CGFloat.pi / 180)))
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                let point = alermCard.selfView.frame.origin
                alermCard.selfView.frame = CGRect(
                    x: point.x,
                    y: point.y,
                    width: alermCard.selfView.frame.width,
                    height: alermCard.selfView.frame.height + alermCard.alermTimeCellList!.height!
                )
                self.view.layoutIfNeeded()
            },
            completion: nil)
    }
    
    func closeAlermTimeCellList(alermCard: AlermCard) {
        alermCard.alermTimeCellList!.heightConstraints!.constant = 0
        alermCard.foot!.pullIcon!.transform = CGAffineTransform(rotationAngle: CGFloat(0 * (CGFloat.pi / 180)))
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                let point = alermCard.selfView.frame.origin
                alermCard.selfView.frame = CGRect(
                    x: point.x,
                    y: point.y,
                    width: alermCard.selfView.frame.width,
                    height: alermCard.selfView.frame.height - alermCard.alermTimeCellList!.height!
                )
                self.view.layoutIfNeeded()

                self.tableView.beginUpdates()
                alermCard.isExpand = false
                self.tableView.endUpdates()
                alermCard.alermTimeCellList!.selfView.alpha = 0
            },
            completion: nil
        )
    }
    
    func layoutIfNeededWithAnimation() {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func presentToSetting(viewController: UIViewController) {
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
    }
    
    func reload() {
        guard self.tableView != nil else { return }
        self.tableView.reloadData()
    }
}

struct AddButton {
    let selfView: UIButton
    var bottomAnchor: NSLayoutConstraint? = nil
    var bottomAnchorInit: CGFloat? = nil
    
    mutating func setBottomAnchor(_ bottomAnchor: NSLayoutConstraint) {
        self.bottomAnchor = bottomAnchor
        self.bottomAnchorInit = bottomAnchor.constant
    }
}
