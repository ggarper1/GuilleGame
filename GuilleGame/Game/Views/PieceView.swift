//
//  PieceView.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 3/10/25.
//

import SwiftUI

private struct SegmentPoint {
    let angle: CGFloat
    let distance: CGFloat
    let point: CGPoint
    let segmentIdx: Int
}

struct PieceView: View {
    @State var piece: Piece
    let segments: [Segment]
    let color: Color
    
    var body: some View {
        ZStack{
            Circle()
                .fill(color)
                .frame(width: Config.pieceRadius * 2, height: Config.pieceRadius * 2)
                .position(piece.position)

            computeFOV()
                .fill(.gray.opacity(0.5))
        }
    }
    
    private func computeCoverage(startAngle: CGFloat, endAngle: CGFloat) -> ([(SegmentPoint?, SegmentPoint?)], [Int]) {
        var allSegmentPoints: [SegmentPoint] = []
        
        for (idx, segment) in segments.enumerated() {
            let startLine = Line(start: piece.position, end: segment.start)
            let endLine = Line(start: piece.position, end: segment.end)
            
            allSegmentPoints.append(SegmentPoint(
                angle: startLine.angle(),
                distance: sqrt(pow(piece.position.x - segment.start.x, 2) + pow(piece.position.y - segment.start.y, 2)),
                point: segment.start,
                segmentIdx: idx,
            ))
            allSegmentPoints.append(SegmentPoint(
                angle: endLine.angle(),
                distance: sqrt(pow(piece.position.x - segment.end.x, 2) + pow(piece.position.y - segment.end.y, 2)),
                point: segment.end,
                segmentIdx: idx,
            ))
        }
        
        let sortedByAngle: [SegmentPoint] = allSegmentPoints.sorted(by: {$0.angle < $1.angle})
        
        var mapSegmentToSP: [(SegmentPoint?, SegmentPoint?)] = Array(repeating: (nil, nil), count: segments.count)
        for sp in sortedByAngle {
            if mapSegmentToSP[sp.segmentIdx].0 == nil {
                mapSegmentToSP[sp.segmentIdx].0 = sp
            } else {
                mapSegmentToSP[sp.segmentIdx].1 = sp
            }
        }
        
        var coverage = sortedByAngle.map({$0.segmentIdx})
        var coverageIndices: [(Int?, Int?)] = Array(repeating: (nil, nil), count: segments.count)
        for (idx, item) in coverage.enumerated() {
            if coverageIndices[item].0 == nil {
                coverageIndices[item].0 = idx
            } else {
                coverageIndices[item].1 = idx
            }
        }
        
        let sortedByDistance = allSegmentPoints.sorted(by: {$0.distance < $1.distance}).reversed()
        for item in sortedByDistance {
            for idx in coverageIndices[item.segmentIdx].0!...coverageIndices[item.segmentIdx].1! {
                coverage[idx] = item.segmentIdx
            }
        }
        
        return (mapSegmentToSP, coverage)
    }
    
    func computeFOV() -> Path {
        ///
        /// Computes FOV
        ///
        let startAngle = piece.angle - Config.semiangleFOV
        let endAngle = piece.angle + Config.semiangleFOV
        
        let (mapSegmentToSP, coverage) = computeCoverage(startAngle: startAngle, endAngle: endAngle)

        var idx: Int = 0
        while idx < coverage.count &&
                mapSegmentToSP[coverage[idx]].1!.angle < startAngle &&
                mapSegmentToSP[coverage[idx]].0!.angle < startAngle {
            idx += 1
        }
        
        var path = Path()
        path.move(to: piece.position)
        guard idx < coverage.count else {
            path.addArc(center: piece.position,
                radius: 400,
                startAngle: Angle(radians: startAngle),
                endAngle: Angle(radians: endAngle),
                clockwise: false)
            
            path.closeSubpath()
            return path
        }
        
        if startAngle < mapSegmentToSP[coverage[idx]].0!.angle {
            path.addArc(center: piece.position,
                radius: 400,
                startAngle: Angle(radians: startAngle),
                endAngle: Angle(radians: mapSegmentToSP[coverage[idx]].0!.angle),
                clockwise: false)
        } else if startAngle > mapSegmentToSP[coverage[idx]].0!.angle {
            let point = Line(point: piece.position, angle: startAngle).intersection(with: segments[coverage[idx]])
            assert(point != nil)
            path.addLine(to: point!)
        } else if startAngle == mapSegmentToSP[coverage[idx]].0!.angle {
            path.addLine(to: mapSegmentToSP[coverage[idx]].0!.point)
        } else {
            assert(false)
        }
        
        var prevSegment: Int = coverage[idx]
        idx += 1
        
        while idx < coverage.count && mapSegmentToSP[coverage[idx]].0!.angle < endAngle {
            let currentSegment: Int = coverage[idx]
            
            guard currentSegment != prevSegment else { continue }
            
            if mapSegmentToSP[prevSegment].1!.angle < mapSegmentToSP[currentSegment].0!.angle {
                path.addLine(to: mapSegmentToSP[prevSegment].1!.point)
                path.addArc(center: piece.position,
                    radius: 400,
                    startAngle: Angle(radians: mapSegmentToSP[prevSegment].1!.angle),
                    endAngle: Angle(radians: mapSegmentToSP[currentSegment].0!.angle),
                    clockwise: false)
                path.addLine(to: mapSegmentToSP[currentSegment].0!.point)
            } else {
                let intersection = Line(point: piece.position, angle: mapSegmentToSP[currentSegment].0!.angle).intersection(with: segments[prevSegment])
                assert(intersection != nil)
                path.addLine(to: intersection!)
                path.addLine(to: mapSegmentToSP[currentSegment].0!.point)
            }
            prevSegment = coverage[idx]
            idx += 1
        }
        
        if mapSegmentToSP[prevSegment].1!.angle < endAngle {
            path.addArc(center: piece.position,
                radius: 400,
                startAngle: Angle(radians: mapSegmentToSP[prevSegment].1!.angle),
                endAngle: Angle(radians: endAngle),
                clockwise: false)
        } else {
            let intersection = Line(point: piece.position, angle: endAngle).intersection(with: segments[prevSegment])
//            assert(intersection != nil)
//            path.addLine(to: intersection!)
//            path.addLine(to: piece.position)
        }
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    var piece = Piece(position: CGPoint(x: 200, y: 200), angle: .pi/2)
    let segments: [Segment] = [Segment(start: CGPoint(x: 100, y: 200), end: CGPoint(x: 100, y: 400))]
    ZStack {
        ForEach(Array(segments.enumerated()), id: \.offset) { index, segment in
            Path { path in
                path.move(to: segment.start)
                path.addLine(to: segment.end)
            }
            .stroke(.black, lineWidth: 2)
        }

        PieceView(piece: piece, segments: segments, color: .blue)
    }
}
