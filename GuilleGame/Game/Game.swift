//
//  Game.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 15/9/25.
//

import SwiftUI

let minSegmentDistance: CGFloat = 10.0
let rectPadding: CGFloat = 20.0

struct Game: View {
    private let segmentGenerator = SegmentGenerator(
        minLength: 50.0,
        maxLength: 150.0,
        minSegmentDistance: minSegmentDistance,
        numSegments: 3
    )
    
    @State private var topSegments: [Segment] = []
    @State private var bottomSegments: [Segment] = []
    @State private var topAreas: [SegmentArea] = []
    @State private var bottomAreas: [SegmentArea] = []
    
    var body: some View {
        GeometryReader { geometry in
            let screenHeight = geometry.size.height
            let screenWidth = geometry.size.width
            
            // Calculate rectangles with padding
            let topRect = CGRect(
                x: rectPadding,
                y: rectPadding,
                width: screenWidth - (rectPadding * 2),
                height: (screenHeight / 2) - (rectPadding * 1.5)
            )
            
            let bottomRect = CGRect(
                x: rectPadding,
                y: (screenHeight / 2) + (rectPadding * 0.5),
                width: screenWidth - (rectPadding * 2),
                height: (screenHeight / 2) - (rectPadding * 1.5)
            )
            
            ZStack {
                // Draw rectangle borders for visualization
                Rectangle()
                    .fill(Color.clear)
                    .stroke(Color.gray, lineWidth: 1)
                    .frame(width: topRect.width, height: topRect.height)
                    .position(x: topRect.midX, y: topRect.midY)
                
                Rectangle()
                    .fill(Color.clear)
                    .stroke(Color.gray, lineWidth: 1)
                    .frame(width: bottomRect.width, height: bottomRect.height)
                    .position(x: bottomRect.midX, y: bottomRect.midY)
                
                // Draw top exclusion areas
                ForEach(Array(topAreas.enumerated()), id: \.offset) { index, area in
                    AreaShape(area: area)
                        .fill(Color.red.opacity(0.2))
                        .stroke(Color.red.opacity(0.5), lineWidth: 1)
                }
                
                // Draw bottom exclusion areas
                ForEach(Array(bottomAreas.enumerated()), id: \.offset) { index, area in
                    AreaShape(area: area)
                        .fill(Color.green.opacity(0.2))
                        .stroke(Color.green.opacity(0.5), lineWidth: 1)
                }
                
                // Draw top lines
                ForEach(Array(topSegments.enumerated()), id: \.offset) { index, segment in
                    Path { path in
                        path.move(to: segment.start)
                        path.addLine(to: segment.end)
                    }
                    .stroke(Color.blue, lineWidth: 2)
                }
                
                // Draw top line start/end points
                ForEach(Array(topSegments.enumerated()), id: \.offset) { index, segment in
                    // Start point (green circle)
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .position(segment.start)
                    
                    // End point (red circle)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .position(segment.end)
                }
                
                // Draw bottom lines
                ForEach(Array(bottomSegments.enumerated()), id: \.offset) { index, segment in
                    Path { path in
                        path.move(to: segment.start)
                        path.addLine(to: segment.end)
                    }
                    .stroke(Color.purple, lineWidth: 2)
                }
                
                // Draw bottom segments start/end points
                ForEach(Array(bottomSegments.enumerated()), id: \.offset) { index, segment in
                    // Start point (green circle)
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                        .position(segment.start)
                    
                    // End point (red circle)
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .position(segment.end)
                }
                
                // Draw top line indices
                ForEach(Array(topSegments.enumerated()), id: \.offset) { index, segment in
                    let midPoint = CGPoint(
                        x: (segment.start.x + segment.end.x) / 2,
                        y: (segment.start.y + segment.end.y) / 2
                    )
                    
                    Text("\(index)")
                        .font(.title)
                        .foregroundColor(.black)
                        .background(Color.white.opacity(1))
                        .position(x: midPoint.x, y: midPoint.y + 15)
                }
                // Draw bottom line indices
                ForEach(Array(bottomSegments.enumerated()), id: \.offset) { index, segment in
                    let midPoint = CGPoint(
                        x: (segment.start.x + segment.end.x) / 2,
                        y: (segment.start.y + segment.end.y) / 2
                    )
                    
                    Text("\(index)")
                        .font(.title)
                        .foregroundColor(.black)
                        .background(Color.white.opacity(1))
                        .position(x: midPoint.x, y: midPoint.y + 15)
                }
                
            }
            .onAppear {
                generateLines(topRect: topRect, bottomRect: bottomRect)
            }
            .onTapGesture {
                generateLines(topRect: topRect, bottomRect: bottomRect)
            }
        }
    }
    
    private func generateLines(topRect: CGRect, bottomRect: CGRect) {
        // Generate lines for top rectangle
        topSegments = segmentGenerator.generateRandomSegments(inRect: topRect)
        topAreas = topSegments.map { segment in
            return SegmentArea(
                segment,
                minSegmentDistance * 2
            )
        }
        
        // Generate lines for bottom rectangle
        bottomSegments = segmentGenerator.generateRandomSegments(inRect: bottomRect)
        bottomAreas = bottomSegments.map { segment in
            return SegmentArea(
                segment,
                minSegmentDistance * 2
            )
        }
    }
}

struct RandomLinesView_Previews: PreviewProvider {
    static var previews: some View {
        Game()
    }
}

#Preview {
    Game()
}
