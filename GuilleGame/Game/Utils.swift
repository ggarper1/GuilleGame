//
//  Utils.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 12/10/25.
//

import Foundation

func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
    let dx = p1.x - p2.x
    let dy = p1.y - p2.y
    return sqrt(dx * dx + dy * dy)
}
