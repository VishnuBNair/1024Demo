//
//  UILabelExtension.swift
//  1024Demo
//
//  Created by Vishnu  Nair on 23/08/21.
//

import Foundation
import UIKit

extension UILabel {
    func labelColorChange(For givenText: NSString,into color: UIColor, from locationNumber: Int, to length: Int){
    let myString:NSString = givenText
    var myMutableString = NSMutableAttributedString()
    myMutableString = NSMutableAttributedString(string: myString as String, attributes: [NSAttributedString.Key.font: UIFont(name: "Palatino", size: 18.0)!])
    myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange(location: locationNumber,length: length))
    // set label Attribute
        self.attributedText = myMutableString
    }
}
