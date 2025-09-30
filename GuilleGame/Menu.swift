//
//  ContentView.swift
//  GuilleGame
//
//  Created by Guillermo Garcia Perez on 15/9/25.
//

import SwiftUI

struct Menu: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("👋 Welcome to the best game ever!").bold().padding(.bottom, 20)
                NavigationLink(
                    destination: Game()
                        .navigationBarBackButtonHidden(true),
                    label: {
                        Text("Start a match")
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(10)
                    })
                .buttonStyle(PlainButtonStyle()) // Keeps the custom style

            }
        }
    }
}

#Preview {
    Menu()
}
