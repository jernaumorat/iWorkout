//
//  PlanView.swift
//  iWorkout
//
//  Created by Nathan on 18/1/22.
//

import Foundation
import SwiftUI

struct AddPlan: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var repsText = ""
    @State private var weightText = ""

    @State private var daySel: DayOfWeek = .monday
    @State private var selExercise = 0

    @FetchRequest(entity: Exercise.entity(), sortDescriptors: [])
    private var exercises: FetchedResults<Exercise>
    
    var body: some View {
        VStack {
            Picker("DoW", selection: $daySel) {
                ForEach(DayOfWeek.allCases, id: \.self.rawValue) { day in
                    Text(day.rawValue.prefix(1).capitalized).tag(day)
                }
            }
            .padding()
            .pickerStyle(.segmented)
            Picker("Exercise", selection: $selExercise) {
                ForEach(0..<exercises.count) { i in
                    Text(exercises[i].name!).tag(i)
                }
            }
            .padding()
            .pickerStyle(.wheel)
            HStack {
                TextField(text: $repsText) {
                    Text("Reps")
                }
                    .padding()
                    .keyboardType(.numberPad)
                TextField(text: $weightText) {
                    Text("kg")
                }
                    .padding()
                    .keyboardType(.decimalPad)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let newWkt = Workout(context: viewContext)
                    let newPln = WorkoutPlan(context: viewContext)
                    
                    newWkt.exercise = exercises[selExercise]
                    newWkt.weight = Double(weightText) ?? 0.0
                    newWkt.repetitions = Int16(repsText) ?? 0
                    
                    newPln.workout = newWkt
                    newPln.dayofweek = daySel.rawValue
                    
                    do {
                        try viewContext.save()
                    } catch let error {
                        print("Error creating workout and plan: \(error)")
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "checkmark")
                }
                    .disabled(repsText == "" || weightText == "")
            }
        }
    }
}

struct DayView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    var day: DayOfWeek
    
    private var planRequest: SectionedFetchRequest<String, WorkoutPlan>
    private var plans: SectionedFetchResults<String, WorkoutPlan> { planRequest.wrappedValue }
    
    init(day: DayOfWeek) {
        self.day = day
        
        self.planRequest = SectionedFetchRequest(
            entity: WorkoutPlan.entity(),
            sectionIdentifier: \WorkoutPlan.workout!.exercise!.category!.name!,
            sortDescriptors: [NSSortDescriptor(keyPath: \WorkoutPlan.workout!.exercise!.category!.name!, ascending: true),
                              NSSortDescriptor(keyPath: \WorkoutPlan.workout!.exercise!.name!, ascending: true),
                              NSSortDescriptor(keyPath: \WorkoutPlan.workout!.weight, ascending: true),
                              NSSortDescriptor(keyPath: \WorkoutPlan.workout!.repetitions, ascending: true)],
            predicate: NSPredicate(format: "dayofweek == %@", day.rawValue),
            animation: .default
        )
    }
    
    var body: some View {
        plans.isEmpty ? AnyView(Text("You have no workouts on \(day.rawValue.capitalized), better create some!").frame(maxHeight: .infinity)) : AnyView(
        List {
            ForEach(plans) { cat in
                Section(cat.id) {
                    ForEach(cat) { plan in
                        VStack(alignment: .leading) {
                            Text("\(plan.workout!.exercise!.name!)")
                            Text("\(weightFormat(plan.workout!.weight)) x \(plan.workout!.repetitions)").font(.caption)
                        }
                    }
                    .onDelete { i in
                        withAnimation {
                            i.map { cat[$0] }.forEach(viewContext.delete)
                            do {
                                try viewContext.save()
                            } catch let error {
                                print("Error deleting exercise: \(error)")
                            }
                        }
                    }
                }
            }
        }.animation(.spring(), value: plans.count))
    }
}

struct PlanView : View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var daySel: DayOfWeek = .monday
    @State private var addActive = false
    @State private var alertEmptyActive = false
    
    @FetchRequest(entity: Exercise.entity(), sortDescriptors: [])
    private var exercises: FetchedResults<Exercise>
    
    @FetchRequest(entity: Workout.entity(), sortDescriptors: [])
    private var workouts: FetchedResults<Workout>
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("DoW", selection: $daySel) {
                    ForEach(DayOfWeek.allCases, id: \.self.rawValue) { day in
                        Text(day.rawValue.prefix(1).capitalized).tag(day)
                    }
                }
                .padding(.horizontal)
                .pickerStyle(.segmented)
                
                DayView(day: daySel)
            }
            .navigationTitle(Text("Workout Plan"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem (placement: .navigationBarTrailing) {
                    Button {
                        if exercises.isEmpty {
                            alertEmptyActive = true
                        } else {
                            addActive = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .background {
                NavigationLink(isActive: $addActive) {
                    AddPlan()
                } label: { EmptyView() }
            }
            .alert(isPresented: $alertEmptyActive) {
                Alert(
                    title: Text("No Exercises"),
                    message: Text("You must create at least one exercise first!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
