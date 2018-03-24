//
//  TerrainVoxelNode.swift
//  CityBuilder
//
//  Created by Alexander Skorulis on 21/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.
//

import Cocoa
import SceneKit


class TerrainVoxelNode: SCNNode {

    let map:TerrainMap
    private let heightMult:CGFloat = 0.5
    let edgeMult:CGFloat = 2
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
        self.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
        
        //let geom = SCNBox(width: 1, height: CGFloat(heightMult), length: 1, chamferRadius: 0)
        //geom.materials = [self.material]
        
        for y in 0..<map.height {
            for x in 0..<map.width {
                let square = map.get(x: x, y: y)
                let geom = provider.getGeometry(map: map, x: x, y: y)
                
                let box = SCNNode(geometry: geom)
                box.position = SCNVector3(CGFloat(x)*edgeMult, CGFloat(square.elevation) * heightMult, CGFloat(y)*edgeMult)
                self.addChildNode(box)
            }
        }
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
