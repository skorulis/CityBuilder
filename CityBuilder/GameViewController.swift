//
//  GameViewController.swift
//  CityBuilder
//
//  Created by Alexander Skorulis on 18/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController, SCNSceneRendererDelegate {
    
    let terrain = TerrainMap(width: 50, height: 50)
    var mapNode: MapNode!
    var scnView:SCNView!
    let camera = IsometricCamera()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let gen = DiamondSquareTerrainGenerator(map: terrain)
        //gen.generate(roughness: 0.6)
        
        mapNode = MapNode(map: terrain)
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 100, z: 10)
        lightNode.light?.intensity = 1000
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = NSColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        scene.rootNode.addChildNode(self.mapNode)
        
        // retrieve the SCNView
        self.scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        //scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = NSColor.black
        
        scnView.delegate = self
        
        //Add a camera to the scene
        camera.addToView(view: scnView)
        
        // Add a click gesture recognizer
        let clickGesture = NSClickGestureRecognizer(target: self, action: #selector(handleClick(_:)))
        scnView.addGestureRecognizer(clickGesture)
        
        let clickGesture2 = NSClickGestureRecognizer(target: self, action: #selector(handleSecondClick(_:)))
        clickGesture2.buttonMask = 2
        scnView.addGestureRecognizer(clickGesture2)
    }
    
    @objc func handleClick(_ gestureRecognizer: NSGestureRecognizer) {
        changeTerrain(gestureRecognizer: gestureRecognizer, amount: 1)
    }
    
    @objc func handleSecondClick(_ gestureRecognizer: NSGestureRecognizer) {
        changeTerrain(gestureRecognizer: gestureRecognizer, amount: -1)
    }
    
    private func changeTerrain(gestureRecognizer: NSGestureRecognizer, amount:Int) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are clicked
        let p = gestureRecognizer.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            let mod = TerrainModification(map: self.terrain)
            let loc = mapNode.terrain.convertPosition(result.localCoordinates, from: result.node)
            
            let x = Int(loc.x / mapNode.setup.edgeMult)
            let y = Int(loc.z / mapNode.setup.edgeMult)
            mod.elevate(x: x, y: y, amount: amount)
            
            mapNode.terrain.buildGeometry()
            mapNode.entities.updateEntityBases()
        }
    }
    
    //MARK: SCNSceneRendererDelegate
    
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //glLineWidth(GLfloat(1))
    }
}
