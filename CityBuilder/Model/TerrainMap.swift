//  Created by Alexander Skorulis on 18/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.

import Cocoa

class TerrainMap: NSObject {

    let width:Int
    let height:Int
    var squares: [TerrainPoint]
    
    init(width:Int,height:Int) {
        self.width = width
        self.height = height
        let squareCount = width * height
        self.squares = [TerrainPoint](repeating: TerrainPoint(), count: squareCount)
        for i in 0..<squareCount {
            self.squares[i] = TerrainPoint()
            self.squares[i].elevation = Float( arc4random_uniform(15))
            //self.squares[i].elevation = Float(i)
        }

        super.init()
    }
    
    func get(x:Int,y:Int) -> TerrainPoint {
        let index = y * width + x
        return self.squares[index]
    }
    
    func getClipped(x:Int,y:Int) -> TerrainPoint? {
        if (x >= 0 && x < width && y >= 0 && y < height) {
            return get(x:x,y:y)
        }
        return nil
    }
    
    func setHeight(x:Int,y:Int,value:Float) {
        get(x:x,y:y).elevation = value
    }
    
    override var debugDescription: String {
        var s = ""
        for y in 0..<height {
            for x in 0..<width {
                let el = Int(get(x: x, y: y).elevation)
                s.append("[\(el)]")
            }
            s.append("\n")
        }
        return s
    }
    
}
