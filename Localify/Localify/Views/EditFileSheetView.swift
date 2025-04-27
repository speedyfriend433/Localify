//
//  EditFileSheetView.swift
//  Localify
//

import SwiftUI

struct EditFileSheetView: View {
    let fileName: String
    let fileType: Project.ProjectFile.FileType
    @Binding var editFileContent: String
    let onCancel: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Editing: \(fileName).\(fileType.rawValue)")) {
                    TextEditor(text: $editFileContent)
                        .frame(minHeight: 400)
                        .font(.system(size: 14, design: .monospaced))
                }
            }
            .navigationTitle("Edit File")
            .navigationBarItems(
                leading: Button("Cancel", action: onCancel),
                trailing: Button("Save", action: onSave)
            )
        }
    }
}