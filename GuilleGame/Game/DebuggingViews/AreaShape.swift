//
//  AreaShape.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 15/9/25.
//

import SwiftUI

struct AreaShape: Shape {
    let area: SegmentArea
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let halfWidth = area.width / 2
        let halfHeight = area.height / 2
        let cos_angle = cos(area.angle)
        let sin_angle = sin(area.angle)
        
        // Rectangle corners in local coordinates
        let corners = [
            CGPoint(x: -halfWidth, y: -halfHeight),
            CGPoint(x: halfWidth, y: -halfHeight),
            CGPoint(x: halfWidth, y: halfHeight),
            CGPoint(x: -halfWidth, y: halfHeight)
        ]
        
        // Transform and add rectangle
        let globalCorners = corners.map { corner in
            CGPoint(
                x: area.center.x + corner.x * cos_angle - corner.y * sin_angle,
                y: area.center.y + corner.x * sin_angle + corner.y * cos_angle
            )
        }
        
        path.move(to: globalCorners[0])
        for i in 1..<globalCorners.count {
            path.addLine(to: globalCorners[i])
        }
        path.closeSubpath()
        
        // Add left semicircle
        let leftCenter = CGPoint(
            x: area.center.x + (-halfWidth) * cos_angle,
            y: area.center.y + (-halfWidth) * sin_angle
        )
        path.addEllipse(in: CGRect(
            x: leftCenter.x - halfHeight,
            y: leftCenter.y - halfHeight,
            width: halfHeight * 2,
            height: halfHeight * 2
        ))
        
        // Add right semicircle
        let rightCenter = CGPoint(
            x: area.center.x + halfWidth * cos_angle,
            y: area.center.y + halfWidth * sin_angle
        )
        path.addEllipse(in: CGRect(
            x: rightCenter.x - halfHeight,
            y: rightCenter.y - halfHeight,
            width: halfHeight * 2,
            height: halfHeight * 2
        ))
        
        return path
    }
}
