//
//  ProjectListView.swift
//  Localify
//

import SwiftUI

struct ProjectListView: View {
    let projects: [Project]
    let selectedProject: Project?
    let onProjectSelect: (Project) -> Void
    let onNewProject: () -> Void
    let onDeleteProject: (Project) -> Void
    
    var body: some View {
        List {
            ForEach(projects) { project in
                Button(action: { onProjectSelect(project) }) {
                    HStack {
                        Image(systemName: "folder")
                        Text(project.name)
                        Spacer()
                        if selectedProject?.id == project.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    onDeleteProject(projects[index])
                }
            }
        }
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onNewProject) {
                    Image(systemName: "plus")
                }
            }
        }
    }
}