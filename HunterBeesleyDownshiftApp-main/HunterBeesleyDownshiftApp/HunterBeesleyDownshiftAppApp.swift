//
//  HunterBeesleyDownshiftAppApp.swift
//  HunterBeesleyDownshiftApp
//
//  Created by Hunter Beesley on 3/17/24.
//

import SwiftUI
import SwiftData

@main
struct HunterBeesleyDownshiftAppApp: App {
    let container: ModelContainer

        var body: some Scene {
            WindowGroup {
                ContentView(modelContext: container.mainContext)
            }
            .modelContainer(container)
        }

        init() {
            do {
                container = try ModelContainer(for: Schema([CarObject.self, FilterObject.self]))
            } catch {
                fatalError("Error creating ModelContainer.")
            }
        }
}
