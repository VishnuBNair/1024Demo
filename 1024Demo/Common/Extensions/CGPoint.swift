//
//  CGPoint.swift
//  1024Demo
//
//  Created by Vishnu  Nair on 23/08/21.
//

import Foundation
import UIKit

extension CGPoint {
    var boardPosition: BoardPosition {
        return (x: Int(self.x), y: Int(self.y))
    }
}
