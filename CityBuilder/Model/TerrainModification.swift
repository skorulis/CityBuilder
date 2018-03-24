//  Created by Alexander Skorulis on 20/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.

import Cocoa

struct PointAdjustment {
    let x:Int
    let y:Int
    var amount:Float
}

class TerrainModification: NSObject {

    private let maxDiff:Float = 3
    
    let map:TerrainMap
    var fixedSquares:[CGPoint] = []
    
    init(map:TerrainMap) {
        self.map = map
    }
    
    func elevate(x:Int,y:Int,amount:Int) {
        elevate(pointAdjustment: PointAdjustment(x: x, y: y, amount: Float(amount)))
    }
    
    func elevate(pointAdjustment:PointAdjustment) {
        let x = pointAdjustment.x
        let y = pointAdjustment.y
        
        if (isFixed(x: x, y: y)) {
            return
        }
        
        fixedSquares.append(CGPoint(x: x, y: y))
        let square = map.get(x: x, y: y)
        square.elevation += pointAdjustment.amount
        
        var adjacent = [PointAdjustment]()
        if (x > 0) {
            adjacent.append(PointAdjustment(x: x-1, y: y, amount: 0))
        }
        if (x < map.width - 1) {
            adjacent.append(PointAdjustment(x: x+1, y: y, amount: 0))
        }
        if (y > 0) {
            adjacent.append(PointAdjustment(x: x, y: y-1, amount: 0))
        }
        if (y < map.height - 1) {
            adjacent.append(PointAdjustment(x: x, y: y+1, amount: 0))
        }
        
        adjacent = adjacent.map({ (pa) -> PointAdjustment in
            let squareAdj = self.map.get(x: pa.x, y: pa.y)
            let diff = square.elevation - squareAdj.elevation
            if (abs(diff) > maxDiff) {
                if (diff > 0) {
                    return PointAdjustment(x: pa.x, y: pa.y, amount: diff - maxDiff)
                } else {
                    return PointAdjustment(x: pa.x, y: pa.y, amount: diff + maxDiff)
                }
            }
            return pa
        })
        adjacent = adjacent.filter({ (pa) -> Bool in
            return pa.amount != 0
        })
        adjacent.forEach { (pa) in
            elevate(pointAdjustment: pa)
        }
    }
    
    func isFixed(x:Int,y:Int) -> Bool {
        let p = CGPoint(x: x, y: y)
        return fixedSquares.contains(p)
    }
    
}
