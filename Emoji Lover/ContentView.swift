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
    @State private var quote: String = ""
    
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
                
                Text(quote)
                    .padding()
                    .multilineTextAlignment(.center)
            }
            .onChange(of: selection) {
                fetchQuote(for: selection)
                playSystemClick()
            }
            .navigationTitle("Emoji Lovers")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
    func fetchQuote(for emoji: Emoji) {
        quote = "Thinking…"

        let prompt = promptText(for: emoji)

        guard let url = URL(string: "http://localhost:11434/api/generate") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "llama3:instruct",
            "prompt": prompt,
            "options": [
                "temperature": 0.8,
                "num_predict": 80
            ],
            "stream": false
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { self.quote = "Network error: \(error.localizedDescription)" }
                return
            }

            guard let http = response as? HTTPURLResponse else {
                DispatchQueue.main.async { self.quote = "Invalid response." }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { self.quote = "No data received." }
                return
            }

            guard (200..<300).contains(http.statusCode) else {
                let bodyText = String(data: data, encoding: .utf8) ?? ""
                DispatchQueue.main.async { self.quote = "HTTP \(http.statusCode): \(bodyText)" }
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let content = json["response"] as? String,
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async { self.quote = content.trimmingCharacters(in: .whitespacesAndNewlines) }
                return
            }

            let bodyText = String(data: data, encoding: .utf8) ?? ""
            DispatchQueue.main.async { self.quote = "Failed to parse response: \(bodyText)" }
        }.resume()
    }
    func promptText(for emoji: Emoji) -> String {
            switch emoji {
            case .😀: return "Write a one-line uplifting quote under 120 characters, no emojis, friendly tone."
            case .😍: return "Write a one-line affectionate love quote under 120 characters, no emojis, wholesome."
            case .😘: return "Write a one-line romantic quote under 120 characters, no emojis, sweet and gentle."
            case .😎: return "Write a one-line confident and cool quote under 120 characters, no emojis, stylish."
            case .😈: return "Write a one-line dirty, playful, naughty quote under 120 characters, no emojis."
            }
        }}

#Preview {
    ContentView()
}
