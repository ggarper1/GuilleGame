//
//  Segment.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 28/9/25.
//

import Foundation

struct Segment {
    let start: CGPoint
    let end: CGPoint
    
    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
    
    var length: CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func isparallel(to segment:Segment) -> Bool {
        return (self.start.x - self.end.x) * (segment.start.y - segment.end.y) - (self.start.y - self.end.y) * (segment.start.x - segment.end.x) == 0
    }
    
    func contains(_ point:CGPoint) -> Bool {
        let dist1 = sqrt(pow(self.start.x - point.x, 2) + pow(self.start.y - point.y, 2))
        let dist2 = sqrt(pow(self.end.x - point.x, 2) + pow(self.end.y - point.y, 2))
        
        return dist1 <= self.length && dist2 <= self.length
    }

    func doesIntersect(with segment:Segment) -> Bool {
        ///
        ///     Returns the true if two segments of a line intersect
        ///
        let denominator = (self.start.x - self.end.x) * (segment.start.y - segment.end.y) - (self.start.y - self.end.y) * (segment.start.x - segment.end.x)
        
        if denominator != 0 {
            let tNumerator = (self.start.x - segment.start.x) * (segment.start.y - segment.end.y) - (self.start.y - segment.start.y) * (segment.start.x - segment.end.x)
            let uNumerator = (self.start.x - self.end.x) * (self.start.y - segment.start.y) - (self.start.y - self.end.y) * (self.start.x - segment.start.x)
            
            let t = tNumerator/denominator
            let u = -uNumerator/denominator
            
            return 0 <= t && t <= 1 && 0 <= u && u <= 1
        } else {
            // In this case segments are parallel, we must check
            // if segments are parallel but belong to different lines:
            if !self.isparallel(to: Segment(start: self.start, end: segment.start)) {
                return false
            }
            // If this code is reached, they are in the same line and we must check if they intersect
            return self.contains(segment.start) || self.contains(segment.end) || segment.contains(self.start) || segment.contains(self.end)
        }
    }
    
    func shortestDistance(to point:CGPoint) -> CGFloat {
        // TODO: fix this!!
        let yDiff = self.end.y - self.start.y
        let xDiff = self.end.x - self.start.x
        
        return abs(yDiff * point.x - xDiff * point.y + self.end.x * self.start.y - self.start.x * self.end.y) / sqrt(pow(yDiff, 2) + pow(xDiff, 2))
    }
}
