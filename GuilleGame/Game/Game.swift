//
//  Game.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 15/9/25.
//

import SwiftUI

let numMatches = 5
let hPlayfieldPadding = 15
let vPlayfieldPadding = 20

struct Game: View {
    @State var match = 0
    let player1Color: Color = .blue
    let player2Color: Color = .red
    @State var matchResults: [MatchResult?] = Array(repeating: nil as MatchResult?, count: numMatches)
    
    var body: some View {
        VStack(spacing: 0) {
            // Score at the top
            Score(player1Color: player1Color, player2Color: player2Color, results: matchResults)
            
            // Get the remaining space for playfield
            GeometryReader { playfieldGeometry in
                let playfieldRect = CGRect(
                    x: hPlayfieldPadding,
                    y: vPlayfieldPadding,
                    width: Int(playfieldGeometry.size.width - CGFloat(2 * hPlayfieldPadding)),
                    height: Int(playfieldGeometry.size.height - CGFloat(2 * vPlayfieldPadding))
                )
                Playfield(playfield: playfieldRect) { player1Won in
                    updateScore(result: MatchResult.player1Won)
                }
            }
        }
    }
    
    func updateScore(result: MatchResult) {
        self.matchResults[self.match] = result
        self.match += 1
    }
}

#Preview {
    Game()
}
