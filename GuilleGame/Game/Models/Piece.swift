//
//  Piece.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 3/10/25.
//

import Foundation

struct Piece {
    let position: CGPoint
    var angle: CGFloat = 0
    
    func distance(to point:CGPoint) -> CGFloat {
        return sqrt(pow(position.x - point.x, 2) + pow(position.y - point.y, 2))
    }
    
    func doesHit(point: CGPoint, segments: [Segment]) -> Bool {
        let line = Line(start: position, end: point)
        
        let lineAngle = line.angle()
        if angle - Config.semiAngleFOV > lineAngle || angle + Config.semiAngleFOV < lineAngle {
            return false
        }
        
        let hitSegment = Segment(start: position, end: point)
        for segment in segments {
            if hitSegment.doesIntersect(with: segment) {
                return false
            }
        }
        
        return true
    }
}
