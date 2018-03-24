//  Created by Alexander Skorulis on 18/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.

import Cocoa
import SceneKit

class TerrainMesh: SCNNode {

    private let heightMult:CGFloat = 0.5
    private let chunkSize:Int = 64
    
    var meshVertices:[SCNVector3] = []
    var materials:[SCNMaterial]!
    let map:TerrainMap
    
    var chunks:[TerrainMeshChunk] = []
    
    init(map:TerrainMap) {
        self.map = map
        super.init()
        
        buildMaterial()
        
        for x in stride(from: 0, to: map.width, by: chunkSize) {
            for y in stride(from: 0, to: map.height, by: chunkSize) {
                let chunk = TerrainMeshChunk(map: map, chunkSize: chunkSize, xOffset: x, yOffset: y)
                chunk.position = SCNVector3(x:CGFloat(x),y:0,z:CGFloat(y))
                self.addChildNode(chunk)
                self.chunks.append(chunk)
            }
        }
        
        buildGeometry()
    }
    
    private func buildMaterial() {
        let material = SCNMaterial()
        material.diffuse.contents = NSColor.systemBlue
        material.isDoubleSided = true
        
        let material2 = SCNMaterial()
        material2.ambient.contents = NSColor.white
        material2.readsFromDepthBuffer = false
        
        self.materials = [material,material2]
    }
    
    func buildGeometry() {
        for chunk in self.chunks {
            chunk.buildGeometry(materials: materials)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
