//
//  VoxelProvider.swift
//  CityBuilder
//
//  Created by Alexander Skorulis on 22/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.
//

import Cocoa
import SceneKit

private extension NSImage.Name {
    static let grassTexture = NSImage.Name("grass")
}

class VoxelProvider: NSObject {

    private var geometryStore:[String:SCNGeometry] = [:]
    private let material:SCNMaterial
    private let heightMult:CGFloat
    private let edgeMult:CGFloat
    
    init(heightMult:CGFloat,edgeMult:CGFloat) {
        self.heightMult = heightMult
        self.edgeMult = edgeMult
        material = SCNMaterial()
        material.diffuse.contents = NSImage(named: .grassTexture)
        //material.diffuse.contents = NSColor.systemRed
    }
    
    func getNinePatch(map:TerrainMap,x:Int,y:Int) -> [[Float]] {
        let square = map.get(x: x, y: y)
        var diffSquare:[[Float]] = Array(repeating:Array(repeating:0,count:3),count:3)
        
        for yA in (y-1)...(y+1) {
            for xA in (x-1)...(x+1) {
                var diff:Float = 0
                
                //Move these as the main params of the loop to simplify
                let yOffset = yA - y
                let xOffset = xA - x
                
                if (abs(xOffset * yOffset) == 1 ) {
                    var total:Float = 0
                    var totalCount:Int = 0
                    let totalOffsets = [(0,0),(xOffset,yOffset),(xOffset,0),(0,yOffset)]
                    for o in totalOffsets {
                        if let adjacent = map.getClipped(x: x+o.0, y: y+o.1) {
                            total += adjacent.elevation
                            totalCount += 1
                        }
                    }
                    let avg = total / Float(totalCount)
                    diff = (avg - square.elevation) * 2 //Not sure why I multiply by 2
                    
                } else if let adjacent = map.getClipped(x: xA, y: yA) {
                    diff = adjacent.elevation - square.elevation
                }
                
                diffSquare[yOffset+1][xOffset+1] = diff
            }
        }
        return diffSquare
    }
    
    func getGeometry(map:TerrainMap,x:Int,y:Int) -> SCNGeometry {
        let diffSquare:[[Float]] = getNinePatch(map: map, x: x, y: y)
        
        let key = "nine-\(diffSquare)"
        
        let gen = ninePatch(neighbours: diffSquare)
        
        return getCachedGeometry(key: key, generator: gen)
    }
    
    func getFlatGeometry(map:TerrainMap,x:Int,y:Int) -> SCNGeometry {
        let square = map.get(x: x, y: y)
        var maxDiff:Float = 0
        for yOffset in -1...1 {
            for xOffset in -1...1 {
                if let adjacent = map.getClipped(x: x+xOffset, y: y+yOffset) {
                    maxDiff = max(maxDiff, square.elevation - adjacent.elevation)
                }
            }
        }
        
        let key = "box-\(maxDiff)";
        let gen = box2(height: CGFloat(maxDiff))
        
        return getCachedGeometry(key: key, generator: gen)
    }
    
    private func getCachedGeometry(key:String,generator:(() -> (SCNGeometry)) ) -> SCNGeometry {
        if let cached = geometryStore[key] {
            return cached
        }
        let geometry = generator()
        geometryStore[key] = geometry
        return geometry
    }
    
    //MARK: - geometry generators
    
    private func ninePatch(neighbours:[[Float]]) -> (() -> SCNGeometry) {
        var meshVertices:[SCNVector3] = Array(repeating:SCNVector3(),count:16)
        var texCoords:[CGPoint] = Array(repeating:CGPoint(),count:16)
        
        let indexFunc = {(x:Int,y:Int) in
            return UInt8(y * 4 + x)
        }
        
        let sideLen:CGFloat = edgeMult/3.0
        let maxEdge:CGFloat = edgeMult/2.0
        
        for z in 0..<4 {
            for x in 0..<4 {
                let index = Int(indexFunc(x, z))
                var y:CGFloat = 0
                if (x == 0 || z == 0 || x == 3 || z == 3) {
                    var dx:Int = 1
                    var dy:Int = 1
                    if (x == 0) {
                        dx = 0
                    } else if (x == 3) {
                        dx = 2
                    }
                    if (z == 0) {
                        dy = 0
                    } else if (z == 3) {
                        dy = 2
                    }
                    
                    y = CGFloat(neighbours[dy][dx]) * 0.5 * CGFloat(heightMult)
                    
                }
                
                meshVertices[index] = SCNVector3(x:CGFloat(x)*sideLen - maxEdge,y:y,z:CGFloat(z)*sideLen - maxEdge)
                texCoords[index] = CGPoint(x: CGFloat(x)*1.0/3.0, y: CGFloat(z)*1.0/3.0)
            }
        }
        
        
        var indices:[UInt8] = Array(repeating:0,count:54)
        
        for y in 0..<3 {
            for x in 0..<3 {
                let baseIndex = (y*3 + x) * 6
                var order = [(0,1),(1,0),(0,0),(1,1),(1,0),(0,1)]
                if (x == y) {
                    order = [(0,0),(0,1),(1,1),(1,1),(1,0),(0,0)]
                }
                for i in 0...5 {
                    indices[baseIndex + i] = indexFunc(x+order[i].0,y+order[i].1)
                }
            }
        }
        
        let vertexSource = SCNGeometrySource(vertices: meshVertices)
        let textureSource = SCNGeometrySource(textureCoordinates: texCoords)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        let geometry = SCNGeometry(sources: [vertexSource,textureSource], elements: [element])
        geometry.materials = [material]
        return {geometry}
    }
    
    private func box(height:Float) -> (() -> SCNGeometry) {
        let geom = SCNBox(width: 1, height: CGFloat(height), length: 1, chamferRadius: 0)
        geom.materials = [self.material]
        return {geom}
    }
    
    private func box2(height:CGFloat) -> (() -> SCNGeometry) {
        return {
            let min1 = -0.5 * self.edgeMult
            let max1 = 0.5 * self.edgeMult
            
            let yMin = -height * self.heightMult
            
            let meshVertices:[SCNVector3] = [SCNVector3(x:min1,y:0,z:min1),SCNVector3(x:min1,y:0,z:max1),SCNVector3(x:max1,y:0,z:max1),SCNVector3(x:max1,y:0,z:min1), SCNVector3(x:min1,y:yMin,z:min1),SCNVector3(x:min1,y:yMin,z:max1),SCNVector3(x:max1,y:yMin,z:max1),SCNVector3(x:max1,y:yMin,z:min1) ]
            
            let texturePoints:[CGPoint] = [CGPoint(x:0,y:0),CGPoint(x:0,y:1),CGPoint(x:1,y:1),CGPoint(x:1,y:0),
                                           CGPoint(x:1,y:0),CGPoint(x:1,y:1),CGPoint(x:1,y:0),CGPoint(x:0,y:0)]
            
            let indices:[UInt8] = [
                0,1,2,2,3,0, //TOP
                4,0,3,3,7,4, //FRONT
                2,1,5,5,6,2, //BACK
                5,1,0,0,4,5, //LEFT
                3,2,6,6,7,3, //RIGHT
                                   ]
            
            let vertexSource = SCNGeometrySource(vertices: meshVertices)
            let textureSource = SCNGeometrySource(textureCoordinates: texturePoints)
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            
            let geometry = SCNGeometry(sources: [vertexSource,textureSource], elements: [element])
            geometry.materials = [self.material]
            return geometry
        }
    }
    
    private func plane() -> (() -> SCNGeometry) {
        let meshVertices:[SCNVector3] = [SCNVector3(x:-0.5,y:0,z:-0.5),SCNVector3(x:-0.5,y:0,z:0.5),SCNVector3(x:0.5,y:0,z:0.5),SCNVector3(x:0.5,y:0,z:-0.5) ]
        let texturePoints:[CGPoint] = [CGPoint(x:0,y:0),CGPoint(x:0,y:1),CGPoint(x:1,y:1),CGPoint(x:1,y:0)]
        
        
        let indices:[UInt8] = [0,1,2,2,3,0]
        
        let vertexSource = SCNGeometrySource(vertices: meshVertices)
        let textureSource = SCNGeometrySource(textureCoordinates: texturePoints)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        
        let geometry = SCNGeometry(sources: [vertexSource,textureSource], elements: [element])
        geometry.materials = [material]
        return {geometry}
    }
    
    
}
