//
//  HelperViews.swift
//  Localify
//

import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct FileRow: View {
    let file: URL
    let isSelected: Bool
    let selectAction: () -> Void
    let editAction: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: iconForFile(file))
                .foregroundColor(colorForFile(file))
            
            Button(action: selectAction) {
                VStack(alignment: .leading) {
                    Text(file.lastPathComponent)
                        .fontWeight(isSelected ? .bold : .regular)
                    
                    Text(fileTypeDescription(for: file))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .padding(.horizontal, 4)
            }
            
            Button(action: editAction) {
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 4)
    }
    
    private func iconForFile(_ file: URL) -> String {
        let ext = file.pathExtension.lowercased()
        switch ext {
        case "html": return "doc.text.image"
        case "js": return "doc.text"
        case "css": return "doc.richtext"
        default: return "doc"
        }
    }
    
    private func colorForFile(_ file: URL) -> Color {
        let ext = file.pathExtension.lowercased()
        switch ext {
        case "html": return .orange
        case "js": return .yellow
        case "css": return .blue
        default: return .gray
        }
    }
    
    private func fileTypeDescription(for file: URL) -> String {
        let ext = file.pathExtension.lowercased()
        switch ext {
        case "html": return "HTML Document"
        case "js": return "JavaScript File"
        case "css": return "CSS Stylesheet"
        default: return "Unknown File Type"
        }
    }
}