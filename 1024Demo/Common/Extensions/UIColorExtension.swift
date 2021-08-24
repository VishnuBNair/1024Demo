//
//  UIColorExtension.swift
//  1024Demo
//
//  Created by Vishnu  Nair on 23/08/21.
//

import Foundation
import UIKit


extension UIColor {
  
  convenience init(_ hex: String, alpha: CGFloat = 1.0) {
    var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if cString.hasPrefix("#") { cString.removeFirst() }
    
    if cString.count != 6 {
      self.init("ff0000") // return red color for wrong hex input
      return
    }
    
    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: alpha)
  }

}

extension UIColor {

    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: 1)
    }

    func hex() -> UInt {

        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        var colorAsUInt: UInt = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            colorAsUInt = UInt(red * 255.0) << 16
            colorAsUInt += UInt(green * 255.0) << 8
            colorAsUInt += UInt(blue * 255.0)
        }
        return colorAsUInt
    }

    class func from(rgb hexValue: UInt) -> UIColor {

        return UIColor(red: CGFloat((hexValue & 0xFF0000) >>  16) / 255.0,
                       green: CGFloat((hexValue & 0x00FF00) >>  8) / 255.0,
                       blue: CGFloat((hexValue & 0x0000FF) >>  0) / 255.0, alpha: 1.0)
    }
}

