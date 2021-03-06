//  Created by Alexander Skorulis on 21/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.

import Cocoa
import SceneKit

class MapNode: SCNNode {

    let setup = TerrainSetupModel()
    let terrain: VoxelTerrain
    var entities:MapEntities!
    //let terrain:TerrainMesh
    
    
    init(map:TerrainMap) {
        //terrain = TerrainMesh(map: map,setup:setup)
        terrain = VoxelTerrain(map: map,setup:setup)
        super.init()
        
        addChildNode(terrain)
        terrain.position = SCNVector3(x: -CGFloat(map.width)*setup.edgeMult/2, y: 0, z: -CGFloat(map.height)*setup.edgeMult/2)
        
        entities = MapEntities(map: self)
        entities.position = terrain.position
        addChildNode(entities)
        
        let pointer = SCNBox(width: 2, height: 2, length: 2, chamferRadius: 0)
        let pointerNode = SCNNode(geometry: pointer)
        pointerNode.position = SCNVector3(x:0,y:0,z:CGFloat(map.height)*setup.edgeMult/2 + 3)
        addChildNode(pointerNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getHeight(x:Int,z:Int) -> CGFloat {
        return terrain.getHeight(x:x,z:z)
    }
}
