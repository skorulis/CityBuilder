//
//  CGPointTests.swift
//  CityBuilderTests
//
//  Created by Alexander Skorulis on 24/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.
//

import XCTest

public class CGPointTests: XCTestCase {

    func testPolarCoords() {
        var point = CGPoint(x: 0, y: -1)
        var angle = point.angle()
        var vector = CGPoint(angle: angle, length: 1)
        XCTAssertEqual(angle, -CGFloat.pi/2)
        XCTAssertEqual(vector.x, point.x, accuracy: 0.0000000001)
        XCTAssertEqual(vector.y, point.y, accuracy: 0.0000000001)
        
        point = CGPoint(x: 1, y: 0)
        angle = point.angle()
        XCTAssertEqual(angle, 0)
        XCTAssertEqual(CGPoint(angle: angle, length: 1), CGPoint(x:1,y:0))
        
        point = CGPoint(x: 0, y: 1)
        angle = point.angle()
        vector = CGPoint(angle: angle, length: 1)
        XCTAssertEqual(angle, CGFloat.pi/2)
        XCTAssertEqual(vector.x, point.x, accuracy: 0.0000000001)
        XCTAssertEqual(vector.y, point.y, accuracy: 0.0000000001)
        
        point = CGPoint(x: -1, y: 0)
        angle = point.angle()
        vector = CGPoint(angle: angle, length: 1)
        XCTAssertEqual(angle, -CGFloat.pi)
        XCTAssertEqual(vector.x, point.x, accuracy: 0.0000000001)
        XCTAssertEqual(vector.y, point.y, accuracy: 0.0000000001)
        
        point = CGPoint(x: -1, y: -1)
        angle = point.angle()
        vector = CGPoint(angle: angle, length: point.length())
        XCTAssertEqual(angle, -3*CGFloat.pi/4)
        XCTAssertEqual(vector.x, point.x, accuracy: 0.0000000001)
        XCTAssertEqual(vector.y, point.y, accuracy: 0.0000000001)
        
        point = CGPoint(x: -1, y: 1)
        angle = point.angle()
        vector = CGPoint(angle: angle, length: point.length())
        XCTAssertEqual(angle, -5*CGFloat.pi/4)
        XCTAssertEqual(vector.x, point.x, accuracy: 0.0000000001)
        XCTAssertEqual(vector.y, point.y, accuracy: 0.0000000001)
    }
    
    func testRotation() {
        var point = CGPoint(x: 1, y: 0)
        point = point.rotate(rad: CGFloat.pi/2)
        XCTAssertEqual(point.x, 0, accuracy: 0.0000000001)
        XCTAssertEqual(point.y, 1, accuracy: 0.0000000001)
        
        point = point.rotate(rad: CGFloat.pi/2)
        XCTAssertEqual(point.x, -1, accuracy: 0.0000000001)
        XCTAssertEqual(point.y, 0, accuracy: 0.0000000001)
        
        point = point.rotate(rad: CGFloat.pi/2)
        XCTAssertEqual(point.x, 0, accuracy: 0.0000000001)
        XCTAssertEqual(point.y, -1, accuracy: 0.0000000001)
        
        point = point.rotate(rad: CGFloat.pi/2)
        XCTAssertEqual(point.x, 1, accuracy: 0.0000000001)
        XCTAssertEqual(point.y, 0, accuracy: 0.0000000001)
        
    }
    
}
