//
//  Piece.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 3/10/25.
//

import Foundation

struct Piece {
    let position: CGPoint
    var angle: CGFloat = 0
    
    func distance(to point:CGPoint) -> CGFloat {
        return sqrt(pow(position.x - point.x, 2) + pow(position.y - point.y, 2))
    }
    
}
