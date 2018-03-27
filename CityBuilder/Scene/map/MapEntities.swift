//  Created by Alexander Skorulis on 27/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.

import Cocoa
import SceneKit

class MapEntities: SCNNode {

    weak var map:MapNode!
    let setup:TerrainSetupModel
    
    private var entities:[SCNNode] = []
    
    init(map:MapNode) {
        self.map = map
        self.setup = map.setup
        super.init()
        
        let tree = TreeEntity()
        addEntity(e: tree, x: 5, z: 5)
        
        let tree2 = TreeEntity()
        addEntity(e: tree2, x: 30, z: 5)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addEntity(e:SCNNode,x:Int,z:Int) {
        let h = map.getHeight(x: x, z: z)
        self.entities.append(e)
        e.position = SCNVector3(x:CGFloat(x)*setup.edgeMult,y:h,z:CGFloat(z)*setup.edgeMult)
        addChildNode(e)
    }
    
    func updateEntityBases() {
        for e in self.entities {
            let x = Int(e.position.x/setup.edgeMult)
            let z = Int(e.position.z/setup.edgeMult)
            let h = map.getHeight(x: x, z: z)
            e.position.y = h
        }
    }
    
    
}
