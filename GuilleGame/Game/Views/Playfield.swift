//
//  Playfield.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 29/9/25.
//

import SwiftUI

// MARK: Playfield display parameters
let middlePadding : CGFloat = 0.02

// MARK: Line generation parameters
let minSegmentSeparation: CGFloat = 20.0
let minLength: CGFloat = 75.0
let maxLength: CGFloat = 200.0
let lineGenerationAreaPadding: CGFloat = 0.05

// MARK: Line display parameters
let segmentWidth: CGFloat = 3.0
let pieceRadius: CGFloat = 5.0  // Size of the colored dots
let userDotRadius: CGFloat = 3.0  // Size of user-placed dots

struct Playfield: View {
    private let player1Color: Color = .blue
    private let player2Color: Color = .red
    private let lineColor: Color = .black
    
    private let playfield: CGRect
    private let lineRectPadding :CGFloat
    
    private let segmentGenerator = SegmentGenerator(
        minLength: minLength,
        maxLength: maxLength,
        minSegmentSeparation: minSegmentSeparation,
        numSegments: 4
    )
    
    // Parent game reference for score update
    var updateScore: ((MatchResult) -> Void)?
    
    // Calculate rectangles with padding
    @State private var topPlayField: CGRect = .zero
    @State private var bottomPlayField: CGRect = .zero
    @State private var topLineRect: CGRect = .zero
    @State private var bottomLineRect: CGRect = .zero
    @State private var topSegments: [Segment] = []
    @State private var bottomSegments: [Segment] = []
    @State private var topAreas: [SegmentArea] = []
    @State private var bottomAreas: [SegmentArea] = []
    
    // Store single piece position for each rectangle
    @State private var topKing: CGPoint = .zero
    @State private var bottomKing: CGPoint = .zero
    
    // User-placed dots
    @State private var topPieces: [CGPoint] = []
    @State private var bottomPieces: [CGPoint] = []
    
    // Game state
    @State private var isPlacingTopDots: Bool = true
    @State private var isPlacingBottomDots: Bool = false
    @State private var gameComplete: Bool = false
    
    init(playfield: CGRect, updateScore: ((MatchResult) -> Void)? = nil) {
        self.playfield = playfield
        self.lineRectPadding = lineGenerationAreaPadding * playfield.width
        self.updateScore = updateScore
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Invisible background to catch all taps
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                
                // Draw rectangle borders for visualization
                Rectangle()
                    .fill(Color.clear)
                    .stroke(isPlacingTopDots ? Color.blue.opacity(0.5) : Color.gray, lineWidth: isPlacingTopDots ? 2 : 1)
                    .frame(width: topPlayField.width, height: topPlayField.height)
                    .position(x: topPlayField.midX, y: topPlayField.midY)
                
                Rectangle()
                    .fill(Color.clear)
                    .stroke(isPlacingBottomDots ? Color.red.opacity(0.5) : Color.gray, lineWidth: isPlacingBottomDots ? 2 : 1)
                    .frame(width: bottomPlayField.width, height: bottomPlayField.height)
                    .position(x: bottomPlayField.midX, y: bottomPlayField.midY)
                
                // Draw top lines
                ForEach(Array(topSegments.enumerated()), id: \.offset) { index, segment in
                    Path { path in
                        path.move(to: segment.start)
                        path.addLine(to: segment.end)
                    }
                    .stroke(lineColor, lineWidth: segmentWidth)
                }
                
                // Draw bottom lines
                ForEach(Array(bottomSegments.enumerated()), id: \.offset) { index, segment in
                    Path { path in
                        path.move(to: segment.start)
                        path.addLine(to: segment.end)
                    }
                    .stroke(lineColor, lineWidth: segmentWidth)
                }
                
                // Draw top king piece (player1 color - blue)
                Circle()
                    .fill(player1Color)
                    .frame(width: pieceRadius * 2, height: pieceRadius * 2)
                    .position(topKing)
                
                // Draw bottom king piece (player2 color - red)
                Circle()
                    .fill(player2Color)
                    .frame(width: pieceRadius * 2, height: pieceRadius * 2)
                    .position(bottomKing)
                
                // Draw user-placed top dots
                ForEach(Array(topPieces.enumerated()), id: \.offset) { index, point in
                    Circle()
                        .fill(player1Color)
                        .frame(width: userDotRadius * 2, height: userDotRadius * 2)
                        .position(point)
                }
                
                // Draw user-placed bottom dots
                ForEach(Array(bottomPieces.enumerated()), id: \.offset) { index, point in
                    Circle()
                        .fill(player2Color)
                        .frame(width: userDotRadius * 2, height: userDotRadius * 2)
                        .position(point)
                }
            }
            .onTapGesture { location in
                handleTap(at: location)
            }
            .onAppear {
                createRects()
                refresh()
            }
        }
    }
    
    private func createRects() {
        topPlayField = CGRect(
            x: playfield.minX,
            y: playfield.minY,
            width: playfield.width,
            height: playfield.height * (1 - middlePadding)/2
        )
        bottomPlayField = CGRect(
            x: playfield.minX,
            y: playfield.minY + playfield.height * (middlePadding + (1 - middlePadding)/2),
            width: playfield.width,
            height: playfield.height * (1 - middlePadding)/2
        )
        topLineRect = CGRect(
            x: playfield.minX + lineRectPadding,
            y: playfield.minY + lineRectPadding,
            width: playfield.width - 2 * lineRectPadding,
            height: playfield.height * (1 - middlePadding)/2 - 2 * lineRectPadding
        )
        bottomLineRect = CGRect(
            x: playfield.minX + lineRectPadding,
            y: playfield.minY + playfield.height * (middlePadding + (1 - middlePadding)/2) + lineRectPadding,
            width: playfield.width - 2 * lineRectPadding,
            height: playfield.height * (1 - middlePadding)/2 - 2 * lineRectPadding
        )
    }
    
    public func generateLines(topRect: CGRect, bottomRect: CGRect) {
        // Generate lines for top rectangle
        topSegments = segmentGenerator.generateRandomSegments(inRect: topRect)
        topAreas = topSegments.map { segment in
            return SegmentArea(
                segment,
                minSegmentSeparation * 2
            )
        }
        
        // Generate lines for bottom rectangle
        bottomSegments = segmentGenerator.generateRandomSegments(inRect: bottomRect)
        bottomAreas = bottomSegments.map { segment in
            return SegmentArea(
                segment,
                minSegmentSeparation * 2
            )
        }
    }
    
    public func refresh() {
        generateLines(topRect: topLineRect, bottomRect: bottomLineRect)
        topKing = segmentGenerator.addPiece(segments: topSegments, rect: topLineRect)
        bottomKing = segmentGenerator.addPiece(segments: bottomSegments, rect: bottomLineRect)
        
        // Reset dot placement
        topPieces = []
        bottomPieces = []
        isPlacingTopDots = true
        isPlacingBottomDots = false
        gameComplete = false
    }
    
    private func handleTap(at location: CGPoint) {
        print("Tap")
        guard !gameComplete else { return }
        
        if isPlacingTopDots {
            print(" Top")
            // Check if tap is in top playfield
            if topPlayField.contains(location) {
                print("  Location correct")
                // Check if position is valid (not on line or king)
                if isValidPosition(location, inRect: topPlayField, segments: topSegments, king: topKing) {
                    print("   Location does not collied")
                    topPieces.append(location)
                    
                    if topPieces.count == 3 {
                        isPlacingTopDots = false
                        isPlacingBottomDots = true
                    }
                }
            }
        } else if isPlacingBottomDots {
            // Check if tap is in bottom playfield
            if bottomPlayField.contains(location) {
                // Check if position is valid (not on line or king)
                if isValidPosition(location, inRect: bottomPlayField, segments: bottomSegments, king: bottomKing) {
                    bottomPieces.append(location)
                    
                    if bottomPieces.count == 3 {
                        isPlacingBottomDots = false
                        gameComplete = true
                        checkWinCondition(topSegments: self.topSegments, topPieces: self.topPieces, topKing: self.topKing, bottomSegments: self.bottomSegments, bottomPieces: self.bottomPieces, bottomKing: self.bottomKing)
                    }
                }
            }
        }
    }
    
    private func isValidPosition(_ point: CGPoint, inRect rect: CGRect, segments: [Segment], king: CGPoint) -> Bool {
        // Check if too close to king piece
        let distance = sqrt(pow(point.x - king.x, 2) + pow(point.y - king.y, 2))
        if distance < (pieceRadius + userDotRadius + 5) {
            return false
        }
        
        // Check if too close to any line segment
        for segment in segments {
            if segment.shortestDistance(to: point) < 5 {
                return false
            }
        }
        // TODO: Check if it collides with other pieces
        
        return true
    }
    
    private func checkWinCondition(
        topSegments: [Segment], topPieces: [CGPoint], topKing: CGPoint,
        bottomSegments: [Segment], bottomPieces: [CGPoint], bottomKing: CGPoint) {
        // TODO: Implement win condition logic here
        // For now, just call updateScore with a placeholder value
        
        // Example condition (replace with actual game logic):
        let result = MatchResult.player1Won // Replace with actual win condition
        
        // Call the updateScore function if provided
        updateScore?(result)
        refresh()
    }
}

#Preview {
    Playfield(playfield: CGRect(x: 20, y: 20, width: 366, height: 700))
}
