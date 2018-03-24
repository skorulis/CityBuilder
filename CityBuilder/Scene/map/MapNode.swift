//  Created by Alexander Skorulis on 21/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.

import Cocoa
import SceneKit

class MapNode: SCNNode {

    let terrain: VoxelTerrain
    
    
    init(map:TerrainMap) {
        terrain = VoxelTerrain(map: map)
        super.init()
        
        addChildNode(terrain)
        terrain.position = SCNVector3(x: -CGFloat(map.width)*terrain.edgeMult/2, y: 0, z: -CGFloat(map.height)*terrain.edgeMult/2)
        
        let pointer = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let pointerNode = SCNNode(geometry: pointer)
        pointerNode.position = SCNVector3(x:0,y:0,z:CGFloat(map.height)*terrain.edgeMult/2 + 3)
        addChildNode(pointerNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
