//
//  Segment Area.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 15/9/25.
//

import Foundation

struct SegmentArea {
    let center: CGPoint
    let width: CGFloat
    let height: CGFloat
    let angle: CGFloat // rotation angle of the rectangle
    
    init(_ segment: Segment, _ areaWidth: CGFloat) {
        self.center = CGPoint(x: (segment.start.x + segment.end.x) / 2, y: (segment.start.y + segment.end.y) / 2)
        self.angle = atan2(segment.end.y - segment.start.y, segment.end.x - segment.start.x)
        self.width = segment.length
        self.height = areaWidth
    }
}
