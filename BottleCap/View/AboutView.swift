//
//  AboutView.swift
//  Bottle Cap
//
//  Created by Richard Picot on 11/11/2023.
//

import SwiftUI

func getAppVersion() -> String {
    guard let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
          let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String else {
        return "Unknown"
    }
    return "Version \(version) (\(build))"
}

struct AboutView: View {
    var body: some View {
        ScrollView {
                VStack(alignment: .center, spacing: 32) {
                    Image("BottleCap")
                        .resizable()
                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .frame(width: 128, height: 128)
                        .padding(.top)
                        .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
                    
                    VStack(spacing: 8) {
                        Text("Bottle Cap")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/.bold())
                        Text("\(getAppVersion())")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                
                        Text("I made Bottle Cap as a way to keep track of my weekly alcohol consumption, without all the details like exact measures or strength. \n\nThis app is intended to help you keep an eye on casual drinking habits. It is not designed to address alcohol addiction. By using Bottle Cap, you acknowledge that you do not have an alcohol dependency. \n\nThe recommended alcohol intake varies significantly from person to person. Bottle Cap is not a replacement for professional medical advice. If you're uncertain about your drinking habits or seeking assistance for addiction, please consult your doctor.")
                    
                    Text("Enjoy, and drink responsibly 🍻")
                        .font(.title3.bold())
                    
                    VStack(spacing: 0) {
                        Text("Made by [Richard Picot](https://mastodon.social/@richardpicot/)")
                        Text("With love from London")
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    
                    
                }
                .padding()
                .multilineTextAlignment(.leading)
                .font(.body)
            

            
        }
        .navigationBarTitle("About", displayMode: .inline)
    }
}

#Preview {
    AboutView()
}
