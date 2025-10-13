import SwiftUI

// MARK: Playfield display parameters
let middlePadding : CGFloat = 0.02

// MARK: Line generation parameters
let minSegmentSeparation: CGFloat = 20.0
let minLength: CGFloat = 75.0
let maxLength: CGFloat = 200.0
let lineGenerationAreaPadding: CGFloat = 0.05

// MARK: Line display parameters
let pieceRadius: CGFloat = 5.0
let userDotRadius: CGFloat = 3.0

struct Playfield: View {
    private let playfield: CGRect
    private let lineRectPadding: CGFloat
    
    private let segmentGenerator = SegmentGenerator(
        minLength: Config.minSegementLength,
        maxLength: Config.maxSegmentLength,
        minSegmentSeparation: Config.minSegmentSeparation,
        numSegments: Config.numSegments
    )
    
    var updateScore: ((MatchResult) -> Void)?
    
    // MARK: Top player elements
    @State private var topPlayField: CGRect = .zero
    @State private var topLineRect: CGRect = .zero
    @State private var topSegments: [Segment] = []
    @State private var topAreas: [SegmentArea] = []
    
    @State private var topKing: CGPoint = .zero
    @State private var topPieces: [Piece] = []
    
    // MARK: Bottom player elements
    @State private var bottomPlayField: CGRect = .zero
    @State private var bottomLineRect: CGRect = .zero
    @State private var bottomSegments: [Segment] = []
    @State private var bottomAreas: [SegmentArea] = []
    
    @State private var bottomKing: CGPoint = .zero
    @State private var bottomPieces: [Piece] = []
    
    // MARK: Player action control state
    @State private var isPlacingTopDots: Bool = true
    @State private var isPlacingBottomDots: Bool = false
    @State private var gameComplete: Bool = false
    
    // MARK: Angle control state
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
                // So you can tap anywhere
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())
                
                // Top Playfield rectangle
                Rectangle()
                    .fill(Color.clear)
                    .stroke(
                        isPlacingTopDots ? Color.blue.opacity(0.5) : Color.gray,
                        lineWidth: isPlacingTopDots ? 2 : 1)
                    .frame(
                        width: topPlayField.width,
                        height: topPlayField.height)
                    .position(
                        x: topPlayField.midX,
                        y: topPlayField.midY)
                
                // Bottom Playfield rectangle
                Rectangle()
                    .fill(Color.clear)
                    .stroke(
                        isPlacingBottomDots ? Color.red.opacity(0.5) : Color.gray,
                        lineWidth: isPlacingBottomDots ? 2 : 1)
                    .frame(
                            width: bottomPlayField.width,
                           height: bottomPlayField.height)
                    .position(
                        x: bottomPlayField.midX,
                        y: bottomPlayField.midY)
                
                // Draw top segments
                ForEach(Array(topSegments.enumerated()), id: \.offset) { index, segment in
                    Path { path in
                        path.move(to: segment.start)
                        path.addLine(to: segment.end)
                    }
                    .stroke(Config.segmentColor, lineWidth: Config.segmentWidth)
                }
                
                // Draw bottom segments
                ForEach(Array(bottomSegments.enumerated()), id: \.offset) { index, segment in
                    Path { path in
                        path.move(to: segment.start)
                        path.addLine(to: segment.end)
                    }
                    .stroke(Config.segmentColor, lineWidth: Config.segmentWidth)
                }
                
                // Draw top king
                Circle()
                    .fill(Config.player1Color)
                    .frame(width: pieceRadius * 2, height: pieceRadius * 2)
                    .position(topKing)
                
                // Draw bottom king
                Circle()
                    .fill(Config.player2Color)
                    .frame(width: pieceRadius * 2, height: pieceRadius * 2)
                    .position(bottomKing)
                
                // Draw top piece views
                ForEach(Array(topPieces.enumerated()), id: \.offset) { index, piece in
                    PieceView(piece: piece, segments: topSegments + bottomSegments, color: Config.player1Color)
                }
                
                // Draw bottom piece views
                ForEach(Array(bottomPieces.enumerated()), id: \.offset) { index, piece in
                    PieceView(piece: piece, segments: topSegments + bottomSegments, color: Config.player2Color)
                }
                
                // Draw temporary piece with PieceView
                if let pos = tempPiecePosition {
                    let currentColor = isPlacingTopDots ? Config.player1Color : Config.player2Color
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
    
    // MARK: Preparing Playfield and Segment generation
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
    
    public func generateSegments(topRect: CGRect, bottomRect: CGRect) {
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
        generateSegments(topRect: topLineRect, bottomRect: bottomLineRect)
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
    
    // MARK: Piece placement
    private func handleDrag(at location: CGPoint, isEnded: Bool) {
        guard !gameComplete else { return }
        
        if isPlacingTopDots {
            if tempPiecePosition == nil && !topPlayField.contains(location) {
                return
            }
            handlePiecePlacement(at: location, isEnded: isEnded)
        } else if isPlacingBottomDots {
            if tempPiecePosition == nil && !bottomPlayField.contains(location) {
                return
            }
            handlePiecePlacement(at: location, isEnded: isEnded)
        }
    }
    
    private func handlePiecePlacement(at location: CGPoint, isEnded: Bool) {
        if tempPiecePosition == nil {
            if isPlacingTopDots && isValidPosition(location, inRect: topPlayField, segments: topSegments, king: topKing) {
                    tempPiecePosition = location
                    tempPieceAngle = .zero
                    isDraggingAngle = false
                
            } else if isValidPosition(location, inRect: bottomPlayField, segments: bottomSegments, king: bottomKing) {
                    tempPiecePosition = location
                    tempPieceAngle = .zero
                    isDraggingAngle = false
            }
        } else if let startPos = tempPiecePosition {
            let dx = location.x - startPos.x
            let dy = location.y - startPos.y
            let distance = sqrt(dx * dx + dy * dy)
            
            if distance > 5 {
                isDraggingAngle = true
                tempPieceAngle = atan2(dy, dx)
            }
            
            if isEnded {
                let newPiece = Piece(position: startPos, angle: tempPieceAngle)
                if isPlacingTopDots {
                    topPieces.append(newPiece)
                } else {
                    bottomPieces.append(newPiece)
                }
                
                tempPiecePosition = nil
                isDraggingAngle = false
                
                if isPlacingTopDots && topPieces.count == 3 {
                    isPlacingTopDots = false
                    isPlacingBottomDots = true
                } else if bottomPieces.count == 3 {
                    isPlacingBottomDots = false
                    gameComplete = true
                    checkWinCondition()
                }
            }
        }
    }
    
    private func isValidPosition(_ point: CGPoint, inRect rect: CGRect, segments: [Segment], king: CGPoint) -> Bool {
        let distance = distance(p1: point, p2: king)
        if distance < (pieceRadius + userDotRadius + Config.minDistanceFromKing) {
            return false
        }
        
        for segment in segments {
            if segment.shortestDistance(to: point) < 5 {
                return false
            }
        }
        
        return true
    }
    
    private func checkWinCondition() {
        let result = MatchResult.player1Won
        updateScore?(result)
        refresh()
    }
}
#Preview {
    Playfield(playfield: CGRect(x: 20, y: 20, width: 366, height: 700))
}
