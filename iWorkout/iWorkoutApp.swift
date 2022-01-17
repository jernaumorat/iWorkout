//
//  iWorkoutApp.swift
//  iWorkout
//
//  Created by Nathan on 17/1/22.
//

import SwiftUI

@main
struct iWorkoutApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
