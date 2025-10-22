//
//  Game.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 15/9/25.
//

import SwiftUI

let numMatches = 2


struct Game: View {
    @State var matchCounter = 0
    @State var matchResults: [MatchResult?] = Array(repeating: nil as MatchResult?, count: numMatches)
    @Environment(\.dismiss) var dismiss
    @State var winner: Int?

    
    var body: some View {
        VStack(spacing: 0) {
            Score(
                player1Color: Config.player1Color,
                player2Color: Config.player2Color,
                results: matchResults,
                winner: winner
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
                
                Playfield(playfield: playfieldRect, winner: winner) { matchResult in
                    updateScore(result: matchResult)
                }
            }
        }
    }

    func updateScore(result: MatchResult) {
        matchResults[matchCounter] = result
        matchCounter += 1
        if (matchCounter == numMatches) {
            let player1Count = matchResults.count(where: {$0 == MatchResult.player1Won})
            let player2Count = matchResults.count(where: {$0 == MatchResult.player2Won})
            if (player1Count > player2Count) {
                winner = 1
            } else if (player1Count < player2Count) {
                winner = 2
            } else {
                winner = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                dismiss()
            }
        }
    }
}

#Preview {
    Game()
}
