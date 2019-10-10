//
//  Color.swift
//  palerm-02
//
//  Created by shuuhei-hanashiro on 2019/10/10.
//  Copyright © 2019 shuuhei-hanashiro. All rights reserved.
//

import UIKit
import Foundation

enum PalermColor: String {
    case Dark50 = "a0a0a0"
    case Dark100 = "505050"
    case Dark200 = "303030"
    case Dark300 = "2a2a2a"
    case Dark400 = "202020"
    case Dark500 = "1a1a1a"
    case Blue = "0d84fa"
    
    var UIColor: UIKit.UIColor {
        return UIKit.UIColor(hexString: self.rawValue)!
    }
}
