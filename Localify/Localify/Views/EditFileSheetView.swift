//
//  EditFileSheetView.swift
//  Localify
//

import SwiftUI
import CodeEditor // Import the CodeEditor library

struct EditFileSheetView: View {
    let fileName: String
    let fileType: Project.ProjectFile.FileType
    @Binding var editFileContent: String
    let onCancel: () -> Void
    let onSave: () -> Void

    // Determine the CodeEditor language based on fileType
    // Determine the CodeEditor language based on fileType
    private var codeEditorLanguage: CodeEditor.Language {
        switch fileType {
        case .css: return .css
        case .js: return .javascript
        default: return .json
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) { // Use VStack to contain the editor
                CodeEditor(
                    source: $editFileContent,
                    language: codeEditorLanguage,
                    theme: .ocean // Use the correct theme name enum
                )
                .frame(minHeight: 400)
            }
            .navigationTitle("Edit File: \(fileName).\(fileType.rawValue)")
            .navigationBarTitleDisplayMode(.inline) // Keep title concise
            .navigationBarItems(
                leading: Button("Cancel", action: onCancel),
                trailing: Button("Save", action: onSave)
            )
        }
    }
}
