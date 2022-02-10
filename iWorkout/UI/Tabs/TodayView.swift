//
//  TodayView.swift
//  iWorkout
//
//  Created by Nathan on 18/1/22.
//

import Foundation
import SwiftUI

struct ItemView : View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var plan : WorkoutPlan
    @State var checked : Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(plan.workout!.exercise!.name!)").font(.title2)
                Text("\(weightFormat(plan.workout!.weight)) x \(plan.workout!.repetitions)")
            }
                
            Spacer()
            Image(systemName: checked ? "checkmark.circle.fill" : "circle")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40, alignment: .trailing)
        }
        .opacity(checked ? 0.5 : 1)
        .contentShape(Rectangle())
        .onTapGesture {
            if !checked {
                let newHist = HistoricalWorkout(context: viewContext)
                newHist.exercise = plan.workout!.exercise!.name!
                newHist.category = plan.workout!.exercise!.category!.name!
                newHist.repetitions = plan.workout!.repetitions
                newHist.weight = plan.workout!.weight
                newHist.timestamp = Date()
                newHist.originalplan = plan
                checked = true
                
                do {
                    try viewContext.save()
                } catch let error {
                    print("Error saving history: \(error)")
                }
            }
        }
        .animation(.linear(duration: 0.1), value: checked)
    }
}

struct TodayView : View {
    @SectionedFetchRequest(
        entity: WorkoutPlan.entity(),
        sectionIdentifier: \WorkoutPlan.workout!.exercise!.category!.name!,
        sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutPlan.workout!.exercise!.category!.name!, ascending: true),
                          NSSortDescriptor(keyPath: \WorkoutPlan.workout!.exercise!.name!, ascending: true)],
        predicate: NSPredicate(format: "dayofweek == %@", argumentArray: [
            todayString().lowercased()]),
        animation: .default
    )
    private var plans: SectionedFetchResults<String, WorkoutPlan>
    
    private var historyRequest: FetchRequest<HistoricalWorkout>
    private var history: FetchedResults<HistoricalWorkout> { historyRequest.wrappedValue }
    
    init() {
        self.historyRequest = FetchRequest(
            entity: HistoricalWorkout.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \HistoricalWorkout.timestamp, ascending: true)],
            predicate: NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", argumentArray: [Date().begin(), Date().end()])
        )
    }
    
    var body: some View {
        NavigationView {
            plans.isEmpty ? AnyView(
                Text("You have no workouts planned for today, take a rest!")
                    .padding()
                    .navigationTitle(todayString().capitalized)
            ) : AnyView (
                List {
                    ForEach(plans) { cat in
                        Section(cat.id) {
                            ForEach(cat) {plan in
                                ItemView(plan: plan, checked: !history.filter{$0.originalplan == plan}.isEmpty)
                                    .padding()
                            }
                        }
                    }
                }
                    .navigationTitle(todayString().capitalized)
            )
        }
    }
}
