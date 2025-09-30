//
//  SegmentGenerator.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 15/9/25.
//

import Foundation

class SegmentGenerator {
    ///
    /// Class for generating segments that are within a certain  distance from one another
    ///
    private let numSegments: Int
    private let minLength: CGFloat
    private let maxLength: CGFloat
    private let minSegmentSeparation: CGFloat
    private let maxAttempts: Int = 20
    
    init(minLength: CGFloat, maxLength: CGFloat, minSegmentSeparation: CGFloat = 20, numSegments: Int = 3) {
        self.minLength = minLength
        self.maxLength = maxLength
        self.minSegmentSeparation = minSegmentSeparation
        self.numSegments = numSegments
    }
    
    func generateRandomSegments(inRect rect: CGRect) -> [Segment] {
        ///
        /// Generates `numSegments` random segments inside `rect` that are at least `minSegmentSeparation` distance from each other
        ///
        var segments: [Segment] = []
        let maxAttempts =  numSegments * 50
        var attempts = 0
        
        while segments.count < numSegments && attempts < maxAttempts {
            attempts += 1
            
            let start = CGPoint(x: CGFloat.random(in: rect.minX...rect.maxX), y: CGFloat.random(in: rect.minY...rect.maxY))
            
            if let end = generateValidEndPoint(from: start, inRect: rect) {
                let segment = Segment(start: start, end: end)
                
                if !hasConflict(segment, segments) {
                    segments.append(segment)
                }
            }
        }
        return segments
    }
    
    private func generateValidEndPoint(from start: CGPoint, inRect rect: CGRect) -> CGPoint? {
        ///
        /// Function for generating a valid endpoint for a given starting point.
        /// It returns a endpoint that satisfies:
        ///      1. The endpoint is in `rect`.
        ///      2. The segment's length has a upper and lower bound (`minLength` and `maxLength`).
        ///
        var attempts = 0
        while attempts < maxAttempts {
            let angle:CGFloat = CGFloat.random(in: 0..<2*CGFloat.pi)
            
            var intersection1:CGPoint? = nil
            var intersection2:CGPoint? = nil
            
            let line = Line(point: start, angle: angle)
            if angle <= CGFloat.pi/2 {
                // Angles in this cuadrant point right and down
                let rightSide = Line(start: CGPoint(x: rect.maxX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.maxY))
                let bottomSide = Line(start: CGPoint(x: rect.minX, y: rect.maxY), end: CGPoint(x: rect.maxX, y: rect.maxY))
                
                intersection1 = line.intersection(with: rightSide)
                intersection2 = line.intersection(with: bottomSide)
                
            } else if angle > CGFloat.pi/2 && angle <= CGFloat.pi {
                // Angles in this cuadrant point left and down
                let leftSide = Line(start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.minX, y: rect.maxY))
                let bottomSide = Line(start: CGPoint(x: rect.minX, y: rect.maxY), end: CGPoint(x: rect.maxX, y: rect.maxY))
                
                intersection1 = line.intersection(with: leftSide)
                intersection2 = line.intersection(with: bottomSide)
                
            } else if angle > CGFloat.pi && angle <= 3 * CGFloat.pi/2 {
                // Angles in this cuadrant point left and up
                let leftSide = Line(start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.minX, y: rect.maxY))
                let topSide = Line(start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.minY))
                
                intersection1 = line.intersection(with: leftSide)
                intersection2 = line.intersection(with: topSide)
                
            } else {
                // Angles in this cuadrant point right and up
                let rightSide = Line(start: CGPoint(x: rect.maxX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.maxY))
                let topSide = Line(start: CGPoint(x: rect.minX, y: rect.minY), end: CGPoint(x: rect.maxX, y: rect.minY))
                
                intersection1 = line.intersection(with: rightSide)
                intersection2 = line.intersection(with: topSide)
            }
            
            var maxRho = maxLength
            
            if let i1 = intersection1 {
                let distance1 = sqrt(pow(start.x - i1.x, 2) + pow(start.y - i1.y, 2))
                maxRho = min(maxRho, distance1)
            }

            if let i2 = intersection2 {
                let distance2 = sqrt(pow(start.x - i2.x, 2) + pow(start.y - i2.y, 2))
                maxRho = min(maxRho, distance2)
            }

            if maxRho > minLength {
                let rho = CGFloat.random(in: minLength...maxRho)
                return CGPoint(x: start.x + rho * cos(angle), y: start.y + rho * sin(angle))
            }
            attempts += 1
        }
        return nil
    }
    
    private func hasConflict(_ segment: Segment, _ segments: [Segment]) -> Bool {
        ///
        /// Checks if a segment is within `minSegmentSeparation` distance of any segment of  a group of segments
        ///
        for existingSegments in segments {
            if areasOverlap(segment, existingSegments) {
                return true
            }
        }
        return false
    }
    
    private func areasOverlap(_ segment1: Segment, _ segment2: Segment) -> Bool {
        ///
        /// Checks if two segments are within areaDistance of eachother
        ///
        return segment1.shortestDistance(to: segment2.start) <= minSegmentSeparation || segment1.shortestDistance(to: segment2.end) <= minSegmentSeparation ||
            segment2.shortestDistance(to: segment1.start) <= minSegmentSeparation || segment2.shortestDistance(to: segment1.end) <= minSegmentSeparation ||
            segment1.doesIntersect(with: segment2)
    }
    
    public func addPiece(segments:[Segment], rect:CGRect) -> CGPoint {
        var attempts = 0
        while attempts < maxAttempts {
            let point = CGPoint(x: CGFloat.random(in: rect.minX...rect.maxX), y: CGFloat.random(in: rect.minY...rect.maxY))
            var isValid = true
            for segment in segments {
                if segment.shortestDistance(to: point) < minSegmentSeparation {
                    isValid = false
                    break
                }
            }
            if isValid {
                return point
            }
            attempts += 1
        }
        return .zero
    }
}
