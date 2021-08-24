//
//  BoardView.swift
//  1024Demo
//
//  Created by Vishnu  Nair on 23/08/21.
//

import Foundation
import UIKit

typealias BoardPosition = (x: Int, y: Int)

class BoardView: UIView {
    let contentInset: CGFloat = 10
    var size = 4 {
        didSet {
            updatePlaceholderLayers()
        }
    }
    var tiles = [BoardTileView]()
    var placeholderLayers = [CALayer]()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePlaceholderLayers()
        animateTiles()
    }
    
    //TileBackground
    func spawnTile(at position: BoardPosition) -> BoardTileView {
        let tile = BoardTileView(frame: frame(at: position))
        tiles.append(tile)
        addSubview(tile)
        tile.backgroundColor = UIColor.clear
        tile.position = position
        tile.cornerRadius = 5
        tile.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).concatenating(CGAffineTransform(rotationAngle: 3.14))
        
        UIView.animate(withDuration: 0.3) {
            tile.alpha = 1
            tile.transform = CGAffineTransform.identity
        }
        
        return tile
    }
    
    //MoveTileFunction
    func moveTile(from: BoardPosition, to: BoardPosition) {
        tile(at: from)?.position = to
    }
    
    
    //Move&RemoveTileFunction
    func moveAndRemoveTile(from: BoardPosition, to: BoardPosition) {
        if let fromTile = tile(at: from), let toTile = tile(at: to) {
            fromTile.destroy = true
            moveTile(from: from, to: to)
            UIView.animate(withDuration: 0.1, animations: {
                toTile.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        toTile.transform = CGAffineTransform.identity
                    }
            })
        }
    }
    
    
    //AnimateTileFunction
    func animateTiles() {
        var destroyed = [BoardTileView]()
        for tile in tiles {
            UIView.animate(withDuration: 0.1, animations: {
                let dest = self.frame(at: tile.position)
                tile.bounds = CGRect(x: 0, y: 0, width: dest.width, height: dest.height)
                tile.layer.position = CGPoint(x: dest.origin.x + dest.width / 2, y: dest.origin.y + dest.height / 2)
                tile.alpha = tile.destroy ? 0 : 1
                }, completion: { _ in
                    if tile.destroy {
                        tile.removeFromSuperview()
                        destroyed.append(tile)
                    }
            })
        }
        tiles = tiles.filter({ tile -> Bool in
            return !destroyed.contains(tile)
        })
    }
    
    
    //UpdateValuesinBoardTile
    func updateValuesWithModel(_ model: [Int], canSpawn: Bool) {
        for y in 0..<model.size {
            for x in 0..<model.size {
                var t = tile(at: (x: x, y: y))
                if canSpawn && model[x, y] > 0 && t == nil {
                    t = spawnTile(at: (x: x, y: y))
                }
                if canSpawn && model[x, y] == 0 && t != nil {
                    tiles.remove(at: tiles.firstIndex(of: t!)!)
                    t!.removeFromSuperview()
                }
                assert(!(t == nil && model[x, y] > 0))
                if let tile = t {
                    tile.value = model[x, y]
                }
            }
        }
    }
    
    
    
    fileprivate func updatePlaceholderLayers() {
        while placeholderLayers.count != size * size {
            if placeholderLayers.count < size * size {
                placeholderLayers.append(CALayer())
                layer.addSublayer(placeholderLayers.last!)
            } else {
                placeholderLayers.last!.removeFromSuperlayer()
                placeholderLayers.removeLast()
            }
        }
        
        for y in 0..<size {
            for x in 0..<size {
                let layer = placeholderLayers[size * x + y]
                layer.backgroundColor = UIColor(red: 204.0/255.0, green: 192.0/255.0, blue: 181.0/255.0, alpha: 1).cgColor
                layer.cornerRadius = 5
                layer.anchorPoint = CGPoint(x: 0, y: 0)
                let rect = frame(at: (x: x, y: y)).insetBy(dx: 5, dy: 5)
                layer.position = rect.origin
                layer.bounds = rect
            }
        }
    }
    
    fileprivate func tile(at position: BoardPosition) -> BoardTileView? {
        return tiles.filter { $0.position == position && !$0.destroy }.first
    }
    
    fileprivate func frame(at position: BoardPosition) -> CGRect {
        let minSize = min(frame.size.width, frame.size.height) - contentInset * 2
        let s = round(minSize / CGFloat(size))
        return CGRect(x: CGFloat(position.x) * s + contentInset, y: CGFloat(position.y) * s + contentInset, width: s, height: s)
    }
    
}
