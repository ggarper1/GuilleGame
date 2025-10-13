//
//  Config.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 3/10/25.
//

import Foundation
import SwiftUI

struct Config {
    // MARK: Playfield paddings
    static let hPlayfieldPadding = 15
    static let vPlayfieldPadding = 20
    
    // MARK: Piece placement
    static let minDistanceFromKing: CGFloat = 5
    
    // MARK: Segment visualization parameters
    static let segmentWidth: CGFloat = 3.0
    static let segmentColor = Color.black
    
    // MARK: Segment generation parameters
    static let minSegmentSeparation: CGFloat = 20.0
    static let minSegementLength: CGFloat = 75.0
    static let maxSegmentLength: CGFloat = 200.0
    static let numSegments: Int = 4
    
    // MARK: Player colors
    static let player1Color = Color.blue
    static let player2Color = Color.red
    
    // MARK: PieceView parameters
    static let pieceRadius: CGFloat = 2
    
    // MARK: PieceView FOV parameeters
    static let reachFOV: CGFloat = 400
    static let semiangleFOV: CGFloat = 20 * (CGFloat.pi * 2)/360
}
