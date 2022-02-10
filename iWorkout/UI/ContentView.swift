//
//  ContentView.swift
//  iWorkout
//
//  Created by Nathan on 17/1/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var tab = 0
    
    var body: some View {
        TabView(selection: $tab) {
            TodayView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Today")
                }.tag(0)
            
            ExerciseView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Exercises")
                }.tag(1)
            
            PlanView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Workout Plan")
                }.tag(2)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "hourglass")
                    Text("History")
                }.tag(3)
            
            DebugView()
                .tabItem {
                    Image(systemName: "wrench.and.screwdriver")
                    Text("Debug")
                }.tag(4)
        }
    }
}
