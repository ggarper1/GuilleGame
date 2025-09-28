//
//  Line.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 15/9/25.
//

import Foundation

struct Line {
    let start: CGPoint
    let end: CGPoint
    
    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
    
    init(point: CGPoint, angle: CGFloat) {
        self.start = point
        self.end = CGPoint(x: point.x + cos(angle) * 2, y: point.x + sin(angle) * 2)
    }
    
    var length: CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func intersection(_ line:Line) -> CGPoint? {
        ///
        ///     Returns the intersection point of two infinite lines if it exists
        ///
        let denominator:CGFloat = (self.start.x - self.end.x) * (line.start.y - line.end.y) - (self.start.y - self.end.y) * (line.start.x - line.end.x)
        if denominator == 0 {
            return nil
        }
        
        let xNumerator:CGFloat = (self.start.x * self.end.y - self.start.y * self.end.x) * (line.start.x - line.end.x) - (self.start.x - self.end.x) * (line.start.x * line.end.y - line.start.y * line.end.x)
        let yNumerator:CGFloat = (self.start.x * self.end.y - self.start.y * self.end.x) * (line.start.y - line.end.y) - (self.start.y - self.end.y) * (line.start.x * line.end.y - line.start.y * line.end.x)
        
        return CGPoint(x: xNumerator/denominator, y: yNumerator/denominator)
    }
    
    func shortestDistance(to point:CGPoint) -> CGFloat {
        let yDiff = self.end.y - self.start.y
        let xDiff = self.end.x - self.start.x
        
        return abs(yDiff * point.x - xDiff * point.y + self.end.x * self.start.y - self.start.x * self.end.y) / sqrt(pow(yDiff, 2) + pow(xDiff, 2))
    }
}
