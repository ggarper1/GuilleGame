//
//  PieceView.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 3/10/25.
//

import SwiftUI

struct PieceView: View {
    @State var piece: Piece
    @State var segments: [Segment]
    let color: Color
    
    var body: some View {
        ZStack{
            Circle()
                .fill(color)
                .frame(width: Config.pieceRadius * 2, height: Config.pieceRadius * 2)
                .position(piece.position)
            drawFOV()
                .fill(.gray.opacity(0.3))
        }
    }
    
    func drawFOV() -> Path {
        var path = Path()
        path.move(to: piece.position)
        path.addArc(
            center: piece.position,
            radius: 400,
            startAngle: Angle(radians: piece.angle - Config.semiAngleFOV),
            endAngle: Angle(radians: piece.angle + Config.semiAngleFOV),
            clockwise: false)
        path.closeSubpath()
        return path
    }
}

#Preview {
    var piece = Piece(position: CGPoint(x: 200, y: 200), angle: .pi/2)
    let segments: [Segment] = [
        //Segment(start: CGPoint(x: 260, y: 440), end: CGPoint(x: 290, y: 440)),
        Segment(start: CGPoint(x: 250, y: 500), end: CGPoint(x: 300, y: 530)),
        Segment(start: CGPoint(x: 100, y: 200), end: CGPoint(x: 200, y: 400)),
        Segment(start: CGPoint(x: 350, y: 190), end: CGPoint(x: 300, y: 500)),
        Segment(start: CGPoint(x: 250, y: 450), end: CGPoint(x: 300, y: 450))
    ]
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
