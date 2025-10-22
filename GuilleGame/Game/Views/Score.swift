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
    let winner: Int? // 1 for player 1, 2 for player 2, nil for ongoing
        
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemGray6)) // background of the container
            .frame(height: 50)
            .overlay(
                Group {
                    if let winner = winner {
                        HStack {
                            Spacer()
                            Text(winner == 1 ? "Player 1 won" : (winner == 2 ? "Player 2 won" : "Tie"))
                                .font(.headline)
                                .foregroundColor(winner == 1 ? player1Color : player2Color)
                            Spacer()
                        }
                    } else {
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
                    }
                }
            )
            .shadow(radius: 1)
            .padding()
    }
}
