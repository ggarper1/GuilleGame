//
//  Score.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 29/9/25.
//

import SwiftUI

struct Score: View {
    let player1Color: Color
    let player2Color: Color
    let results: [MatchResult?]
        
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6)) // background of the container
            .frame(height: 50)
            .overlay(
                HStack(spacing: 12) {
                    ForEach(0..<results.count, id: \.self) { index in
                        switch results[index] {
                        case .player1Won:
                            Circle()
                                .fill(player1Color)
                                .frame(width: 16, height: 16)
                        case .player2Won:
                            Circle()
                                .fill(player2Color)
                                .frame(width: 16, height: 16)
                        case .tie:
                            Circle()
                                .fill(.yellow)
                                .frame(width: 16, height: 16)
                        case nil:
                            Circle()
                                .fill(.gray)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .padding(.horizontal, 12)
            )
            .shadow(radius: 1)
            .padding()
    }
}

#Preview {
    VStack(spacing: 20) {
        Score(player1Color: .blue, player2Color: .red, results: [MatchResult.player1Won, MatchResult.player2Won, MatchResult.tie, nil])
    }
    .padding()
    .background(Color.white)
}
