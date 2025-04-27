//
//  ProjectCreationView.swift
//  Localify
//

import SwiftUI

struct ProjectCreationView: View {
    @Binding var showNewProjectSheet: Bool
    @State private var newProjectName = ""
    let onCreate: (String) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project name", text: $newProjectName)
                }
            }
            .navigationTitle("New Project")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showNewProjectSheet = false
                },
                trailing: Button("Create") {
                    onCreate(newProjectName)
                    showNewProjectSheet = false
                }
                .disabled(newProjectName.isEmpty)
            )
        }
    }
}