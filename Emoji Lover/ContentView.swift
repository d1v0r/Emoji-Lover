//
//  ContentView.swift
//  Emoji Lover
//
//  Created by Davor Gotal on 13.11.2025..
//

import SwiftUI
import AudioToolbox

func playSystemClick() {
    AudioServicesPlaySystemSound(1104)
}

enum Emoji: String, CaseIterable{
    case 😀, 😍, 😘, 😎, 😈
}

struct ContentView: View {
    @State var selection: Emoji = .😀
    var body: some View {
        NavigationView {
            VStack{
                Text(selection.rawValue)
                    .font(.system(size: 150))
                
                Picker("Select Emoji", selection: $selection){
                    ForEach(Emoji.allCases, id: \.self){ emoji in
                        Text(emoji.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
            .onChange(of: selection) { playSystemClick() }
            .navigationTitle("Emoji Lovers")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
