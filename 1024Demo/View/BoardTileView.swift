//
//  BoardTileView.swift
//  1024Demo
//
//  Created by Vishnu  Nair on 23/08/21.
//

import Foundation
import UIKit

typealias ColorScheme = [String : [String : String]]

class BoardTileView: UIView {

    var destroy = false
    var position = (x: -1, y: -1)
    override var cornerRadius: CGFloat {
        didSet {
            valueLabel.layer.cornerRadius = cornerRadius
        }
    }
    var value = -1 {
        didSet {
            if !valueHidden {
                valueLabel.text = "\(value)"
            }
            valueLabel.backgroundColor = colorForType()
            valueLabel.textColor = UIColor.white
        }
    }
    var valueHidden = false {
        didSet {
            if valueHidden {
                valueLabel.text = ""
            }
        }
    }
    var colorScheme: ColorScheme?
    var valueLabel = UILabel()
    private var isSetup = false
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    //SetUpTileLabel
    fileprivate func setup() {
        guard !isSetup else { return }
        isSetup = true
        alpha = 0
        
        valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.boldSystemFont(ofSize: 70)
        valueLabel.minimumScaleFactor = 0.4
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.textAlignment = .center
        valueLabel.clipsToBounds = true
        valueLabel.baselineAdjustment = .alignCenters
        valueLabel.backgroundColor = UIColor(white: 0.5, alpha: 0.2)
        
        self.addSubview(valueLabel)
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-p-[valueLabel]-p-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: ["p": 5], views: ["valueLabel" : valueLabel]))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-p-[valueLabel]-p-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: ["p": 5], views: ["valueLabel" : valueLabel]))
    }
    
    
    //TileBackgroubdColor
    fileprivate func colorForType() -> UIColor {
        return UIColor.red
    }
}





