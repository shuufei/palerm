//
//  Extension.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/10/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit
import Foundation

extension UIColor {
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        let validatedHexColorCode = hexString.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: validatedHexColorCode)
        var colorCode: UInt64 = 0
        
        guard scanner.scanHexInt64(&colorCode) else {
            print("ERROR: 色変換に失敗しました。")
            return nil
        }
        
        let R = CGFloat((colorCode & 0xFF0000) >> 16) / 255.0
        let G = CGFloat((colorCode & 0x00FF00) >> 8) / 255.0
        let B = CGFloat(colorCode & 0x0000FF) / 255.0
        self.init(red: R, green: G, blue: B, alpha: alpha)
    }
}

extension UIStackView {
    func addBackground(_ color: UIColor, _ cornerRadius: CGFloat = 0, _ top: Bool = false, _ shadow: Bool = false) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.layer.cornerRadius = cornerRadius
        if top {
            subView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if shadow {
            subView.layer.shadowColor = UIColor.black.cgColor
            subView.layer.shadowOpacity = 0.3
            subView.layer.shadowRadius = 16
            subView.layer.shadowOffset = CGSize(width: 0, height: 5)
        }
        insertSubview(subView, at: 0)
    }
}
