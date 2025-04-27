//
//  ProjectViews.swift
//  Localify
//

import SwiftUI

struct ProjectRow: View {
    let project: Project
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(project.name)
                    .font(.headline)
                Text("\(project.files.count) files")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
}

struct ProjectDetailView: View {
    let project: Project
    let onFileSelect: (Project.ProjectFile) -> Void
    let onFileEdit: (Project.ProjectFile) -> Void
    
    var body: some View {
        List {
            ForEach(project.files) { file in
                ProjectFileRow(file: file) {
                    onFileSelect(file)
                } editAction: {
                    onFileEdit(file)
                }
            }
        }
        .navigationTitle(project.name)
    }
}

struct ProjectFileRow: View {
    let file: Project.ProjectFile
    let onSelect: () -> Void
    let editAction: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: fileTypeIcon)
                .foregroundColor(fileTypeColor)
            
            VStack(alignment: .leading) {
                Text(file.name)
                    .font(.headline)
                Text(".(file.type.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: editAction) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
    }
    
    private var fileTypeIcon: String {
        switch file.type {
        case .html: return "doc.text"
        case .css: return "paintbrush"
        case .js: return "chevron.left.slash.chevron.right"
        }
    }
    
    private var fileTypeColor: Color {
        switch file.type {
        case .html: return .orange
        case .css: return .purple
        case .js: return .yellow
        }
    }
}

struct NewProjectSheet: View {
    @Binding var isPresented: Bool
    let onCreate: (String) -> Void
    
    @State private var projectName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Details")) {
                    TextField("Project name", text: $projectName)
                }
            }
            .navigationTitle("New Project")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Create") {
                    onCreate(projectName)
                    isPresented = false
                }
                .disabled(projectName.isEmpty)
            )
        }
    }
}
