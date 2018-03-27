//  Created by Alexander Skorulis on 27/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.

import Cocoa
import SceneKit

class TreeEntity: SCNNode {

    override init() {
        super.init()
        
        let inner = SCNNode(geometry: SCNCone(topRadius: 0, bottomRadius: 0.5, height: 2))
        inner.position = SCNVector3(0, 1, 0)
        self.addChildNode(inner)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
