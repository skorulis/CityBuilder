//  Created by Alexander Skorulis on 24/3/18.
//  Copyright © 2018 Alex Skorulis. All rights reserved.

import Cocoa

extension CGPoint {

    public init(angle:CGFloat,length:CGFloat) {
        let x = length * cos(angle)
        let y = length * sin(angle)
        self.init(x:x,y:y)
    }
    
    public func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    public func angle() -> CGFloat {
        if (x < 0) {
            return atan(y/x) - CGFloat.pi
        } else {
            return atan(y/x)
        }
    }
    
    public func rotate(rad:CGFloat) -> CGPoint {
        let angle = self.angle() + rad
        return CGPoint(angle:angle,length:length())
    }
    
}
