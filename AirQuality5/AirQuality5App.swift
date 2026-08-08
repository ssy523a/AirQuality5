//
//  AirQuality5App.swift
//  AirQuality5
//
//  Created by Seyoung Seo on 8/8/26.
//

import AppKit
import SwiftUI

@main
struct AirQuality5App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .defaultSize(width: 900, height: 850)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button(AppText.aboutAirQuality) {
                    showAboutPanel()
                }
            }
        }
    }

    private func showAboutPanel() {
        let credits = NSAttributedString(
            string: "Seo, Seyoung\nssy523a@gmail.com",
            attributes: [
                .font: NSFont.systemFont(ofSize: 13),
                .foregroundColor: NSColor.secondaryLabelColor
            ]
        )

        NSApplication.shared.orderFrontStandardAboutPanel(options: [
            .credits: credits
        ])
    }
}
