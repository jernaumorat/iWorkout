//
//  DebugView.swift
//  iWorkout
//
//  Created by Nathan on 25/1/22.
//

import Foundation
import SwiftUI

let test_data: [String: [String: [(Double, Int16, DayOfWeek)]]] = [
    "Chest": [
        "Benchpresses": [
            (10.0, 15, .monday),
            (25.0, 5, .monday)
        ],
        "Pushups": [
            (0, 10, .monday),
            (0, 30, .thursday)
        ],
    ],
    "Legs": [
        "Kettlebell Squats": [
            (10.0, 15, .wednesday),
            (10.0, 25, .friday)
        ],
        "Lunges": [],
        "Star Jumps": [
            (0, 25, .friday)
        ],
    ],
    "Arms": [
        "Bar Curls": [
            (15, 10, .tuesday)
        ],
    ],
    "Back": [
        :
    ],
    "Core": [
        "Situps": [
            (0, 30, .monday),
            (0, 35, .wednesday),
            (0, 40, .friday)
        ],
        "Crunches": [
            (0, 25, .monday)
        ],
    ],
    "Shoulders": [
        "Atlasing": [
            (5.97e24, 1, .sunday)
        ],
    ],
    "Wrists": [
        :
    ],
    "Fingertips": [
        "Mobile App Development": [
            (0, 1000, .monday),
            (0, 1000, .tuesday),
            (0, 1000, .wednesday),
            (0, 1000, .thursday),
            (0, 1000, .friday),
            (0, 1000, .sunday),
        ],
    ],
    "Prana": [
        :
    ],
    "Bindu": [
        :
    ]
]

struct DebugView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: Category.entity(), sortDescriptors: [])
    private var categories: FetchedResults<Category>
    @FetchRequest(entity: Exercise.entity(), sortDescriptors: [])
    private var exercises: FetchedResults<Exercise>
    @FetchRequest(entity: Workout.entity(), sortDescriptors: [])
    private var workouts: FetchedResults<Workout>
    @FetchRequest(entity: WorkoutPlan.entity(), sortDescriptors: [])
    private var plans: FetchedResults<WorkoutPlan>
    @FetchRequest(entity: HistoricalWorkout.entity(), sortDescriptors: [])
    private var history: FetchedResults<HistoricalWorkout>
    
    func deleteAll() {
        for cat in categories {
            viewContext.delete(cat)
        }
        for exc in exercises {
            viewContext.delete(exc)
        }
        for wrk in workouts {
            viewContext.delete(wrk)
        }
        for pln in plans {
            viewContext.delete(pln)
        }
        for hst in history {
            viewContext.delete(hst)
        }
        do {
            try viewContext.save()
        } catch let err {
            print("Error deleting all: \(err)")
        }
    }
    
    func addData() {
        for cat in test_data {
            let newCat = Category(context: viewContext)
            newCat.name = cat.key
            
            for exc in cat.value {
                let newExc = Exercise(context: viewContext)
                newExc.name = exc.key
                newExc.category = newCat
                
                for wrk in exc.value {
                    let newWrk = Workout(context: viewContext)
                    let newPln = WorkoutPlan(context: viewContext)
                    newWrk.weight = wrk.0
                    newWrk.repetitions = wrk.1
                    newWrk.exercise = newExc
                    newPln.dayofweek = wrk.2.rawValue
                    newPln.workout = newWrk
                }
            }
        }
        
        do {
            try viewContext.save()
        } catch let err {
            print("Error creating testdata: \(err)")
        }
    }
    
    func addHistory() {
        let plns = plans.shuffled().prefix(upTo: 5)
        for plan in plns {
            let newHist = HistoricalWorkout(context: viewContext)
            newHist.exercise = plan.workout!.exercise!.name!
            newHist.category = plan.workout!.exercise!.category!.name!
            newHist.repetitions = plan.workout!.repetitions
            newHist.weight = plan.workout!.weight
            newHist.timestamp = generateRandomDate(daysBack: 14)
            newHist.originalplan = plan
        }
        
        do {
            try viewContext.save()
        } catch let err {
            print("Error creating test history: \(err)")
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Button("Delete All Coredata") {
                    deleteAll()
                }.padding()
                Button("Add Fake Data") {
                    addData()
                }.padding()
                Button("Add Fake History") {
                    addHistory()
                }.padding()
            }
        }
    }
}
