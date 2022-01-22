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

    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Today")
                }
            
            ExerciseView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Exercises")
                }
            
            PlanView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Workout Plan")
                }
            
            HistoryView()
                .tabItem {
                    Image(systemName: "hourglass")
                    Text("History")
                }
        }
        
    }

//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
