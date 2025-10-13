//
//  Game.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 15/9/25.
//

import SwiftUI

let numMatches = 5


struct Game: View {
    @State var matchCounter = 0
    @State var matchResults: [MatchResult?] = Array(repeating: nil as MatchResult?, count: numMatches)
    
    var body: some View {
        VStack(spacing: 0) {
            Score(
                player1Color: Config.player1Color,
                player2Color: Config.player2Color,
                results: matchResults
            )
            
            GeometryReader { playfieldSpace in
                // Get the remaining space for playfield
                let width =
                    playfieldSpace.size.width - CGFloat(2 * Config.hPlayfieldPadding)
                let height =
                    playfieldSpace.size.height - CGFloat(2 * Config.vPlayfieldPadding)
                
                let playfieldRect = CGRect(
                    x: Config.hPlayfieldPadding,
                    y: Config.vPlayfieldPadding,
                    width: Int(width),
                    height: Int(height)
                )
                
                Playfield(playfield: playfieldRect) { matchResult in
                    updateScore(result: matchResult)
                }
            }
        }
    }
    
    func updateScore(result: MatchResult) {
        matchResults[matchCounter] = result
        matchCounter += 1
    }
}

#Preview {
    Game()
}
