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
                    Image("Headshot")
                        .resizable()
                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .frame(width: 128, height: 128)
                        .clipShape(.circle)
                    
                    Text("I made Bottle Cap because I wanted a simple way to track my alcohol consumption over the course of a week, with the goal of improving my health. I hope you find it useful.")
                        .multilineTextAlignment(.center)
                        .font(.title3.bold())
                    
                    Text("Enjoy, and drink responsibly 🍻")
                        .multilineTextAlignment(.center)
                        .font(.title3.bold())
                    
                    VStack(spacing: 0) {
                        Text("Bottle Cap \(getAppVersion())")
                        Text("By [Richard Picot](https://mastodon.social/@richardpicot/)")
                        Text("Made in London")
                    }
                    .font(.body)
                    .foregroundStyle(.secondary)
                }
            

            
        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        .navigationBarTitle("About", displayMode: .inline)
    }
}

#Preview {
    AboutView()
}
