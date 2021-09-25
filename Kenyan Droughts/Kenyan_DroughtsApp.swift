//
//  Kenyan_DroughtsApp.swift
//  Kenyan Droughts
//
//  Created by Bidan on 25/09/2021.
//

import SwiftUI

@main
struct Kenyan_DroughtsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
