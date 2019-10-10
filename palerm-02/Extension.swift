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
        var colorCode: UInt32 = 0
        
        guard scanner.scanHexInt32(&colorCode) else {
            print("ERROR: 色変換に失敗しました。")
            return nil
        }
        
        let R = CGFloat((colorCode & 0xFF0000) >> 16) / 255.0
        let G = CGFloat((colorCode & 0x00FF00) >> 8) / 255.0
        let B = CGFloat(colorCode & 0x0000FF) / 255.0
        self.init(red: R, green: G, blue: B, alpha: alpha)
    }
}
