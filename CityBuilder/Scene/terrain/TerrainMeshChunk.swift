//  Created by Alexander Skorulis on 20/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.

import Cocoa
import SceneKit

class TerrainMeshChunk: SCNNode {
    
    let chunkSize:Int
    let xOffset:Int
    let yOffset:Int
    let setup:TerrainSetupModel
    
    let map:TerrainMap
    
    init(map:TerrainMap,setup:TerrainSetupModel,xOffset:Int,yOffset:Int) {
        self.map = map
        self.chunkSize = setup.chunkSize
        self.xOffset = xOffset
        self.yOffset = yOffset
        self.setup = setup
        super.init()
    }
    
    func buildGeometry(materials:[SCNMaterial]) {
        let xMax = min(xOffset + chunkSize,map.width-1)
        let yMax = min(yOffset + chunkSize,map.height-1)
        
        let xCount = xMax - xOffset + 1
        let yCount = yMax - yOffset + 1
        
        let vertextCount = xCount * yCount
        
        var meshVertices:[SCNVector3] = Array(repeating:SCNVector3(),count:vertextCount)
        for y in yOffset...yMax {
            for x in xOffset...xMax {
                let yIndex = y - yOffset
                let xIndex = x - xOffset
                let square = self.map.get(x: x, y: y)
                let index = yIndex * xCount + xIndex
                meshVertices[index].x = CGFloat(x - xOffset) * setup.edgeMult
                meshVertices[index].z = CGFloat(y - yOffset) * setup.edgeMult
                meshVertices[index].y = CGFloat(square.elevation) * setup.heightMult
            }
        }
        
        let indiceCount = (yCount-1) * (xCount-1) * 6
        
        var indices:[UInt16] = Array(repeating:0,count:indiceCount)
        for y in 0..<yCount - 1 {
            for x in 0..<xCount - 1 {
                let baseIndex = (y * (xCount-1) + x) * 6
                indices[baseIndex] = UInt16(y * xCount + x)
                indices[baseIndex + 1] = UInt16(y * xCount + x + 1)
                indices[baseIndex + 2] = UInt16((y+1) * xCount + x)
                
                indices[baseIndex + 3] = UInt16(y * xCount + x + 1)
                indices[baseIndex + 4] = UInt16((y+1) * xCount + x + 1)
                indices[baseIndex + 5] = UInt16((y+1) * xCount + x)
            }
        }
        
        let vertexSource = SCNGeometrySource(vertices: meshVertices)
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let gridElement = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        let geometry = SCNGeometry(sources: [vertexSource], elements: [element,gridElement])
        geometry.materials = materials
        
        self.geometry = geometry
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var debugDescription: String {
        return "Chunk @ (\(xOffset),\(yOffset))"
    }
    
}
