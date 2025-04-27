//
//  NewFileSheetView.swift
//  Localify
//

import SwiftUI

struct NewFileSheetView: View {
    @Binding var newFileName: String
    @Binding var newFileType: Project.ProjectFile.FileType
    @Binding var newFileContent: String
    let fileTypes: [String]
    let templates: [String: String]
    let onCancel: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("File Details")) {
                    TextField("File name", text: $newFileName)
                    
                    Picker("File Type", selection: $newFileType) {
                        ForEach(fileTypes, id: \.self) { type in
                            Text(".\(type)").tag(Project.ProjectFile.FileType(rawValue: type) ?? .html)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button("Use Template") {
                        if let template = templates[newFileType.rawValue] {
                            newFileContent = template
                        }
                    }
                    .buttonStyle(.bordered)
                }
                
                Section(header: Text("Content")) {
                    TextEditor(text: $newFileContent)
                        .frame(minHeight: 300)
                        .font(.system(size: 14, design: .monospaced))
                }
            }
            .navigationTitle("New File")
            .navigationBarItems(
                leading: Button("Cancel", action: onCancel),
                trailing: Button("Save", action: onSave)
                    .disabled(newFileName.isEmpty)
            )
        }
    }
}