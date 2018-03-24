//
//  IsometricCamera.swift
//  CityBuilder
//
//  Created by Alexander Skorulis on 23/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.
//

import Cocoa
import SceneKit

class IsometricCamera: SCNNode {

    private let kCameraZoomSpeed:CGFloat = 20
    private let kCameraMaxDistance:CGFloat = 100
    private let kCameraMinDistance:CGFloat = 4
    
    var lastMagnification:CGFloat = 0
    var lastRotation:CGFloat = 0
    var lastTranslation:NSPoint = .zero
    
    var targetPoint = SCNVector3()
    
    
    override init() {
        super.init()
        self.camera = SCNCamera()
        self.camera?.zFar = 1000
        
        self.position = SCNVector3(x: 0, y: 20, z: -20)
        self.look(at: targetPoint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addToView(view:SCNView) {
        view.scene!.rootNode.addChildNode(self)
        setupGestures(view:view)
    }
    
    private func setupGestures(view:SCNView) {
        let magGesture = NSMagnificationGestureRecognizer(target: self, action: #selector(pinched(gesture:)))
        view.addGestureRecognizer(magGesture)
        
        let panGesture = NSPanGestureRecognizer(target: self, action: #selector(panned(gesture:)))
        view.addGestureRecognizer(panGesture)
        
        let rotGesture = NSRotationGestureRecognizer(target: self, action: #selector(rotated(gesture:)))
        view.addGestureRecognizer(rotGesture)
    }
    
    @objc func pinched(gesture:NSMagnificationGestureRecognizer) {
        if (gesture.state == .began) {
            lastMagnification = 0
        } else if (gesture.state == .changed) {
            let distance = self.targetPoint.distance(vector: self.position)
            let dir = (self.targetPoint - self.position).normalized()
            
            let diff = gesture.magnification - lastMagnification
            var movAmount = diff * kCameraZoomSpeed * sqrt(distance)
            if (movAmount < 0) {
                movAmount = max(movAmount,-5)
            } else {
                movAmount = min(movAmount,5)
            }
            
            self.position = self.position + (dir * movAmount)
            
            let distNew = self.targetPoint.distance(vector: self.position)
            if (distNew < kCameraMinDistance) {
                self.position = self.targetPoint - dir * kCameraMinDistance
            } else if (distNew > kCameraMaxDistance) {
                self.position = self.targetPoint - dir * kCameraMaxDistance
            }
            
            lastMagnification = gesture.magnification
        }
    }
    
    @objc func panned(gesture:NSPanGestureRecognizer) {
        let trans = gesture.translation(in: gesture.view)
        
        if (gesture.state == .began) {
            lastTranslation = trans
        } else if (gesture.state == .changed) {
            let mov = SCNVector3(x:(trans.x - lastTranslation.x) * 0.3,y:0,z:(lastTranslation.y - trans.y) * 0.3)
            
            self.targetPoint += mov
            self.position += mov
            self.look(at: self.targetPoint)
            
            lastTranslation = trans
        }
    }
    
    //Broken
    @objc func rotated(gesture:NSRotationGestureRecognizer) {
        if (gesture.state == .began) {
            lastRotation = gesture.rotation
        } else if (gesture.state == .changed) {
            let diff = lastRotation - gesture.rotation
            let dir = self.position - self.targetPoint
            let xzDir = CGPoint(x: dir.x, y: dir.z)
            let newPos = xzDir.rotate(rad: diff)
            self.position = SCNVector3(x:newPos.x,y:self.position.y,z:newPos.y)
            self.look(at: self.targetPoint)
            //self.look(at: self.targetPoint, up: SCNVector3(x:0,y:1,z:0), localFront: <#T##SCNVector3#>)
            
            lastRotation = gesture.rotation
        }
    }
    
}
