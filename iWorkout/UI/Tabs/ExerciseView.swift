//
//  ExerciseView.swift
//  iWorkout
//
//  Created by Nathan on 18/1/22.
//

import Foundation
import SwiftUI

struct AddCategory : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var labelText = ""
    
    var body: some View {
        VStack {
            TextField(text: $labelText) {
                Text("Category Label")
            }
                .padding(70)
                .textFieldStyle(.roundedBorder)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let newCat = Category(context: viewContext)
                    newCat.name = labelText
                    do {
                        try viewContext.save()
                    } catch let error {
                        print("Error creating category: \(error)")
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Save")
                }
                    .disabled(labelText == "")
            }
        }
        .navigationTitle(Text("Add new Category"))
    }
}

struct AddExercise : View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)], animation: .default)
    private var categories: FetchedResults<Category>
    
    @State private var labelText = ""
    @State private var pickerSel = 0
    
    var body: some View {
        VStack {
            TextField(text: $labelText) {
                Text("Exercise Label")
            }
                .padding(.horizontal, 70)
                .textFieldStyle(.roundedBorder)
            Picker("Category", selection: $pickerSel) {
                ForEach(0..<categories.count) { i in
                    Text(categories[i].name!).tag(i)
                }
            }
            .pickerStyle(.inline)
            .padding(.horizontal, 70)
            .lineLimit(5)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let newEx = Exercise(context: viewContext)
                    newEx.name = labelText
                    newEx.category = [categories[pickerSel]]
                    do {
                        try viewContext.save()
                    } catch let error {
                        print("Error creating exercise: \(error)")
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Text("Save")
                }
                    .disabled(labelText == "")
            }
        }
        .navigationTitle(Text("Add new Exercise"))
    }
}

struct CategoryDetail : View {
    var category: Category
    
    var body: some View {
        if category.exercise?.count ?? 0 > 0 {
            List {
                ForEach(Array(category.exercise as? Set<Exercise> ?? [])) {ex in
                    Text(ex.name!)
                }
            }
            .padding()
            .navigationTitle(category.name!)
        } else {
            Text("No exercises belong to this category, go create some!")
                .padding()
                .multilineTextAlignment(.center)
                .navigationTitle(category.name!)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ExerciseView : View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var tabSel = false
    
    @State private var addCategory = false
    @State private var addActive = false
    
    @State private var alertEmptyActive = false
    @State private var confirmationShown = false

    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)], animation: .default)
    private var categories: FetchedResults<Category>
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Exercise.name, ascending: true)], animation: .default)
    private var exercises: FetchedResults<Exercise>
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Tab", selection: $tabSel) {
                    Text("Categories").tag(false)
                    Text("Exercises").tag(true)
                }
                .padding()
                .pickerStyle(.segmented)
                
                if !tabSel {
                    List {
                        ForEach(categories, id: \.self.id) { cat in
                            NavigationLink(cat.name!) { CategoryDetail(category: cat) }
                            .swipeActions {
                                Button (
                                    role: .destructive,
                                    action: { confirmationShown = true }
                                ) {
                                    Text("Delete")
                                }
                            }
                            .confirmationDialog(
                                "Are you sure you want to delete this category? Exercises belonging to the category will also be deleted!",
                                isPresented: $confirmationShown,
                                titleVisibility: .visible
                            ) {
                                Button("Delete", role: .destructive) {
                                    withAnimation {
                                        viewContext.delete(cat)
                                        do {
                                            try viewContext.save()
                                        } catch let error {
                                            print("Error deleting category: \(error)")
                                        }
                                    }
                                    confirmationShown = false
                                }
                                Button("Cancel", role: .cancel) {}
                            }
                        }
                    }
                    .padding()
                    .navigationTitle(Text("Categories"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                addCategory = true
                                addActive = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .animation(.spring(), value: categories.count)
                } else {
                    List {
                        ForEach(exercises) { exc in
                            Text(exc.name!)
                        }
                        .onDelete { i in
                            withAnimation {
                                i.map { exercises[$0] }.forEach(viewContext.delete)
                                do {
                                    try viewContext.save()
                                } catch let error {
                                    print("Error deleting exercise: \(error)")
                                }
                            }
                        }
                    }
                    .padding()
                    .navigationTitle(Text("Exercises"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                if !categories.isEmpty {
                                    addCategory = false
                                    addActive = true
                                } else {
                                    alertEmptyActive = true
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .animation(.spring(), value: exercises.count)
                }
            }
            .background {
                NavigationLink (isActive: $addActive) {
                    addCategory ? AnyView(AddCategory()) : AnyView(AddExercise())
                } label: {
                    EmptyView()
                }
            }
            .alert(isPresented: $alertEmptyActive) {
                Alert(
                    title: Text("No Categories"),
                    message: Text("You must create at least one category first!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}
