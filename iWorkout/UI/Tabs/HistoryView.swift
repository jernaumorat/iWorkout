//
//  HistoryView.swift
//  iWorkout
//
//  Created by Nathan on 18/1/22.
//

import Foundation
import SwiftUI

func twentyfourToTwelve (_ hour: Int) -> Int {
    if hour == 0 {
        return 12
    }
    if hour > 12 {
        return hour - 12
    }
    return hour
}

struct TimeView : View {
    let cal = Calendar.current
    var time: Date
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 2) {
                Text(String(format: "%02d", twentyfourToTwelve(cal.component(.hour, from: time))))
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                Text("\(cal.component(.hour, from: time) > 11 ? "P" : "A")")
                    .font(.system(size: 20, weight: .heavy, design: .monospaced))
            }
            HStack(alignment: .center, spacing: 2) {
                Text(String(format: "%02d", cal.component(.minute, from: time)))
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                Text("M")
                    .font(.system(size: 20, weight: .heavy, design: .monospaced))
            }
        }
        .frame(width: 45, height: 45, alignment: .center)
    }
}

struct DateList : View {
    private var historyRequest: FetchRequest<HistoricalWorkout>
    private var history: FetchedResults<HistoricalWorkout> { historyRequest.wrappedValue }
    
    @Binding var shareString: String
    @Binding var selDate: Date
    
    init(date: Binding<Date>, shareString: Binding<String>) {
        self._shareString = shareString
        self._selDate = date
        
        self.historyRequest = FetchRequest(
            entity: HistoricalWorkout.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \HistoricalWorkout.timestamp, ascending: true)],
            predicate: NSPredicate(format: "timestamp >= %@ AND timestamp <= %@", argumentArray: [date.wrappedValue.begin(), date.wrappedValue.end()])
        )
    }
    
    var body: some View {
        List {
            ForEach(history) {workout in
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(workout.category!): \(workout.exercise!)")
                        Text("\(weightFormat(workout.weight)) x \(workout.repetitions)").font(.caption)
                    }
                    Spacer()
                    TimeView(time: workout.timestamp!)
                }
            }
        }
        .onReceive(history.publisher.count()) { c in
            var msg = ""
            if c > 0 {
                msg = "On \(selDate.formatted(.dateTime.day().month().year())), I completed these workouts:"
                for workout in history {
                    msg += "\n\(workout.timestamp!.formatted(.dateTime.hour().minute())): \(workout.category!) - \(workout.exercise!) @ \(weightFormat(workout.weight)) x \(workout.repetitions)"
                }
            } else {
                msg = "I did not complete any workouts on \(selDate.formatted(.dateTime.day().month().year())) :("
            }
            shareString = msg
        }
    }
}

struct HistoryView : View {
    @State private var dateSel: Date = Date()
    @State private var shareString = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                DatePicker("Date", selection: $dateSel, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                
                DateList(date: $dateSel, shareString: $shareString)
                    .frame(maxHeight: .infinity)
            }
            .navigationTitle("Workout History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        let activityController = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
                        UIApplication.shared.currentUIWindow()!.rootViewController!.present(activityController, animated: true, completion: nil)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}
