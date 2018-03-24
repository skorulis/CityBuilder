//  Created by Alexander Skorulis on 21/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.

import Cocoa
import SceneKit


class VoxelTerrain: SCNNode {

    let map:TerrainMap
    private let heightMult:CGFloat = 0.5
    let edgeMult:CGFloat = 5
    private let provider:VoxelProvider
    
    var material:SCNMaterial!
    
    init(map:TerrainMap) {
        self.map = map
        self.provider = VoxelProvider(heightMult: heightMult,edgeMult:edgeMult)
        super.init()
        buildMaterial()
        buildGeometry()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildGeometry() {
        //let geom = SCNBox(width: 1, height: CGFloat(heightMult), length: 1, chamferRadius: 0)
        //geom.materials = [self.material]
        
        for y in 0..<map.height {
            for x in 0..<map.width {
                let square = map.get(x: x, y: y)
                
                let node = getNode(x: x, y: y)
                node.geometry = provider.getFlatGeometry(map: map, x: x, y: y)
                node.position = SCNVector3(CGFloat(x)*edgeMult, CGFloat(square.elevation) * heightMult, CGFloat(y)*edgeMult)
                self.addChildNode(node)
            }
        }
    }
    
    private func getNode(x:Int,y:Int) -> SCNNode {
        let index = y * map.width + x
        if (index < self.childNodes.count) {
            return self.childNodes[index]
        }
        return SCNNode()
    }
    
    private func buildMaterial() {
        let material = SCNMaterial()
        
        material.isDoubleSided = false
        
        let material2 = SCNMaterial()
        material2.ambient.contents = NSColor.white
        material2.readsFromDepthBuffer = false
        
        self.material = material
    }
    
}
