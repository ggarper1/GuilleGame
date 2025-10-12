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
let pieceRadius: CGFloat = 5.0
let userDotRadius: CGFloat = 3.0

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
    
    var updateScore: ((MatchResult) -> Void)?
    
    @State private var topPlayField: CGRect = .zero
    @State private var bottomPlayField: CGRect = .zero
    @State private var topLineRect: CGRect = .zero
    @State private var bottomLineRect: CGRect = .zero
    @State private var topSegments: [Segment] = []
    @State private var bottomSegments: [Segment] = []
    @State private var topAreas: [SegmentArea] = []
    @State private var bottomAreas: [SegmentArea] = []
    
    @State private var topKing: CGPoint = .zero
    @State private var bottomKing: CGPoint = .zero
    
    @State private var topPieces: [Piece] = []
    @State private var bottomPieces: [Piece] = []
    
    @State private var isPlacingTopDots: Bool = true
    @State private var isPlacingBottomDots: Bool = false
    @State private var gameComplete: Bool = false
    
    // Angle control state
    @State private var tempPiecePosition: CGPoint? = nil
    @State private var tempPieceAngle: CGFloat = .zero
    @State private var isDraggingAngle: Bool = false
    
    init(playfield: CGRect, updateScore: ((MatchResult) -> Void)? = nil) {
        self.playfield = playfield
        self.lineRectPadding = lineGenerationAreaPadding * playfield.width
        self.updateScore = updateScore
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                
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
                
                ForEach(Array(topSegments.enumerated()), id: \.offset) { index, segment in
                    Path { path in
                        path.move(to: segment.start)
                        path.addLine(to: segment.end)
                    }
                    .stroke(lineColor, lineWidth: segmentWidth)
                }
                
                ForEach(Array(bottomSegments.enumerated()), id: \.offset) { index, segment in
                    Path { path in
                        path.move(to: segment.start)
                        path.addLine(to: segment.end)
                    }
                    .stroke(lineColor, lineWidth: segmentWidth)
                }
                
                Circle()
                    .fill(player1Color)
                    .frame(width: pieceRadius * 2, height: pieceRadius * 2)
                    .position(topKing)
                
                Circle()
                    .fill(player2Color)
                    .frame(width: pieceRadius * 2, height: pieceRadius * 2)
                    .position(bottomKing)
                
                ForEach(Array(topPieces.enumerated()), id: \.offset) { index, piece in
                    PieceView(piece: piece, segments: topSegments + bottomSegments, color: player1Color)
                }
                
                ForEach(Array(bottomPieces.enumerated()), id: \.offset) { index, piece in
                    PieceView(piece: piece, segments: topSegments + bottomSegments, color: player2Color)
                }
                
                // Draw temporary piece with PieceView
                if let pos = tempPiecePosition {
                    let currentColor = isPlacingTopDots ? player1Color : player2Color
                    let tempPiece = Piece(position: pos, angle: tempPieceAngle)
                    
                    PieceView(piece: tempPiece, segments: topSegments + bottomSegments, color: currentColor)
                        .opacity(0.7)
                        .id(tempPieceAngle)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDrag(at: value.location, isEnded: false)
                    }
                    .onEnded { value in
                        handleDrag(at: value.location, isEnded: true)
                    }
            )
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
        topSegments = segmentGenerator.generateRandomSegments(inRect: topRect)
        topAreas = topSegments.map { segment in
            return SegmentArea(segment, minSegmentSeparation * 2)
        }
        
        bottomSegments = segmentGenerator.generateRandomSegments(inRect: bottomRect)
        bottomAreas = bottomSegments.map { segment in
            return SegmentArea(segment, minSegmentSeparation * 2)
        }
    }
    
    public func refresh() {
        generateLines(topRect: topLineRect, bottomRect: bottomLineRect)
        topKing = segmentGenerator.addPiece(segments: topSegments, rect: topLineRect)
        bottomKing = segmentGenerator.addPiece(segments: bottomSegments, rect: bottomLineRect)
        
        topPieces = []
        bottomPieces = []
        isPlacingTopDots = true
        isPlacingBottomDots = false
        gameComplete = false
        tempPiecePosition = nil
        isDraggingAngle = false
    }
    
    private func handleDrag(at location: CGPoint, isEnded: Bool) {
        guard !gameComplete else { return }
        
        if isPlacingTopDots {
            // Allow initial placement only in top playfield, but allow dragging anywhere for angle
            if tempPiecePosition == nil && !topPlayField.contains(location) {
                return
            }
            handleTopPiecePlacement(at: location, isEnded: isEnded)
        } else if isPlacingBottomDots {
            // Allow initial placement only in bottom playfield, but allow dragging anywhere for angle
            if tempPiecePosition == nil && !bottomPlayField.contains(location) {
                return
            }
            handleBottomPiecePlacement(at: location, isEnded: isEnded)
        }
    }
    
    private func handleTopPiecePlacement(at location: CGPoint, isEnded: Bool) {
        if tempPiecePosition == nil {
            if isValidPosition(location, inRect: topPlayField, segments: topSegments, king: topKing) {
                tempPiecePosition = location
                tempPieceAngle = .zero
                isDraggingAngle = false
            }
        } else {
            if let startPos = tempPiecePosition {
                let dx = location.x - startPos.x
                let dy = location.y - startPos.y
                let distance = sqrt(dx * dx + dy * dy)
                
                if distance > 5 {
                    isDraggingAngle = true
                    tempPieceAngle = atan2(dy, dx)
                }
                
                if isEnded {
                    let newPiece = Piece(position: startPos, angle: tempPieceAngle)
                    topPieces.append(newPiece)
                    
                    tempPiecePosition = nil
                    isDraggingAngle = false
                    
                    if topPieces.count == 3 {
                        isPlacingTopDots = false
                        isPlacingBottomDots = true
                    }
                }
            }
        }
    }
    
    private func handleBottomPiecePlacement(at location: CGPoint, isEnded: Bool) {
        if tempPiecePosition == nil {
            if isValidPosition(location, inRect: bottomPlayField, segments: bottomSegments, king: bottomKing) {
                tempPiecePosition = location
                tempPieceAngle = .zero
                isDraggingAngle = false
            }
        } else {
            if let startPos = tempPiecePosition {
                let dx = location.x - startPos.x
                let dy = location.y - startPos.y
                let distance = sqrt(dx * dx + dy * dy)
                
                if distance > 5 {
                    isDraggingAngle = true
                    tempPieceAngle = atan2(dy, dx)
                }
                
                if isEnded {
                    let newPiece = Piece(position: startPos, angle: tempPieceAngle)
                    bottomPieces.append(newPiece)
                    
                    tempPiecePosition = nil
                    isDraggingAngle = false
                    
                    if bottomPieces.count == 3 {
                        isPlacingBottomDots = false
                        gameComplete = true
                        checkWinCondition(
                            topSegments: self.topSegments,
                            topPieces: self.topPieces,
                            topKing: self.topKing,
                            bottomSegments: self.bottomSegments,
                            bottomPieces: self.bottomPieces,
                            bottomKing: self.bottomKing
                        )
                    }
                }
            }
        }
    }
    
    private func isValidPosition(_ point: CGPoint, inRect rect: CGRect, segments: [Segment], king: CGPoint) -> Bool {
        let distance = sqrt(pow(point.x - king.x, 2) + pow(point.y - king.y, 2))
        if distance < (pieceRadius + userDotRadius + 5) {
            return false
        }
        
        for segment in segments {
            if segment.shortestDistance(to: point) < 5 {
                return false
            }
        }
        
        return true
    }
    
    private func checkWinCondition(
        topSegments: [Segment], topPieces: [Piece], topKing: CGPoint,
        bottomSegments: [Segment], bottomPieces: [Piece], bottomKing: CGPoint) {
        let result = MatchResult.player1Won
        updateScore?(result)
        refresh()
    }
}
#Preview {
    Playfield(playfield: CGRect(x: 20, y: 20, width: 366, height: 700))
}
