//
//  DiamondSquareTerrainGenerator.swift
//  CityBuilder
//
//  Created by Alexander Skorulis on 20/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.
//

import Cocoa

class DiamondSquareTerrainGenerator: NSObject {

    let map:TerrainMap
    
    init(map:TerrainMap) {
        self.map = map
    }
    
    func generate(roughness: Float) {
        let max = map.width - 1 // The maximum index.
        
        // Initial corner values.
        map.setHeight(x: 0,   y: 0,   value: frand())
        map.setHeight(x: max, y: 0,   value: frand())
        map.setHeight(x: 0,   y: max, value: frand())
        map.setHeight(x: max, y: max, value: frand())
        
        // Fill it in.
        
        var subSize = max
        var randomScale:Float = 1
        
        while(subSize > 1) {
            for y in stride(from: 0, to: max-1, by: subSize) {
                for x in stride(from: 0, to: max-1, by: subSize) {
                    diamond(x: x, y: y, size: subSize, randomScale: randomScale)
                }
            }
            for y in stride(from: 0, to: max-1, by: subSize) {
                for x in stride(from: 0, to: max-1, by: subSize) {
                    square(x: x, y: y, size: subSize, randomScale: randomScale)
                }
            }
            
            subSize /= 2
            randomScale *= roughness
        }
            
    }
    
    func diamond(x: Int, y: Int, size: Int, randomScale: Float) {
        let tl = map.get(x: x,        y: y)
        let tr = map.get(x: x + size, y: y)
        let bl = map.get(x: x,        y: y + size)
        let br = map.get(x: x + size, y: y + size)
        let avg = (tl.elevation + tr.elevation + bl.elevation + br.elevation) / 4
        
        let point = map.get(x: x + size/2, y: y + size/2)
        point.elevation = avg + frand() * randomScale
    }
    
    /// Sets the midpoints of the sides of the square to be the average of the 3 or
    /// 4 horiz/vert points plus a random value.
    func square(x: Int, y: Int, size: Int, randomScale: Float) {
        // Get all the inputs.
        let half = size/2
        let tl = map.get(x: x,        y: y)
        let tr = map.get(x: x + size, y: y)
        let bl = map.get(x: x,        y: y + size)
        let br = map.get(x: x + size, y: y + size)
        let m  = map.get(x: x + half, y: y + half)
        let above = map.getClipped(x: x + half,        y: y - half)
        let below = map.getClipped(x: x + half,        y: y + size + half)
        let left  = map.getClipped(x: x - half,        y: y + half)
        let right = map.getClipped(x: x + size + half, y: y + half)
        
        let topValue = average(tl.elevation, tr.elevation, m.elevation, above?.elevation) + frand() * randomScale
        let bottomValue = average(bl.elevation, br.elevation, m.elevation, below?.elevation) + frand() * randomScale
        let leftValue = average(tl.elevation, bl.elevation, m.elevation, left?.elevation)  + frand() * randomScale
        let rightValue = average(tr.elevation, br.elevation, m.elevation, right?.elevation) + frand() * randomScale
        
        // Set the sides.
        map.setHeight(x: x + half, y: y,        value: topValue) // Top
        map.setHeight(x: x + half, y: y + size, value: bottomValue) // Bottom
        map.setHeight(x: x,        y: y + half, value: leftValue) // Left
        map.setHeight(x: x + size, y: y + half, value: rightValue) // Right
        
    }
    
    /// Average of the 3 or 4 inputs.
    private func average(_ a: Float, _ b: Float, _ c: Float, _ d: Float?) -> Float {
        if let d = d {
            return (a+b+c+d) / 4
        } else {
            return (a+b+c) / 3
        }
    }
    
    func frand() -> Float {
        return Float(drand48() * 15)
    }
    
}
