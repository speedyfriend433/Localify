//
//  TabViews.swift
//  Localify
//

import SwiftUI

struct ServerTabView: View {
    let serverURL: String
    let fileTypes: [String]
    
    var body: some View {
        NavigationView {
            VStack {
                if !serverURL.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 10))
                            Text("Server Status: Running")
                                .font(.headline)
                        }
                        
                        Text("Server URL: \(serverURL)")
                            .font(.subheadline)
                        
                        Text("Files are being served from your Documents directory")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Divider()
                        
                        Text("Server Information")
                            .font(.headline)
                            .padding(.top, 8)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "Port", value: "8080")
                            InfoRow(label: "Protocol", value: "HTTP")
                            InfoRow(label: "File Types", value: fileTypes.joined(separator: ", "))
                        }
                        .padding(.vertical, 4)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 1)
                    .padding()
                } else {
                    VStack {
                        ProgressView()
                            .padding()
                        Text("Starting server...")
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Server")
        }
    }
}

struct FilesTabView: View {
    let files: [URL]
    let selectedFileURL: URL?
    let fileTypes: [String]
    let onFileSelect: (URL) -> Void
    let onFileEdit: (URL) -> Void
    let onNewFile: () -> Void
    let onImportFile: () -> Void
    let onRefresh: () -> Void
    let onDelete: (IndexSet) -> Void
    
    var body: some View {
        NavigationView {
            List {
                ForEach(files, id: \.self) { file in
                    FileRow(file: file, isSelected: selectedFileURL == file) {
                        onFileSelect(file)
                    } editAction: {
                        onFileEdit(file)
                    }
                }
                .onDelete(perform: onDelete)
            }
            .navigationTitle("Files")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: onNewFile) {
                            Label("Create New File", systemImage: "doc.badge.plus")
                        }
                        
                        Button(action: onImportFile) {
                            Label("Import from Files", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: onRefresh) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

struct PreviewTabView: View {
    let selectedFileURL: URL?
    let serverURL: String
    let onEdit: () -> Void
    let onGoToFiles: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if let selectedFileURL = selectedFileURL {
                    let projectID = selectedFileURL.deletingLastPathComponent().lastPathComponent // Extract project ID
                    let fileName = selectedFileURL.lastPathComponent // Extract file name with extension
                    if let url = URL(string: "\(serverURL)projects/\(projectID)/\(fileName)") {
                        // Note: Assumes selectedFileURL format is like ".../ProjectID/filename.ext"
                        VStack {
                            Text(selectedFileURL.lastPathComponent)
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            WebView(url: url)
                                .cornerRadius(10)
                            
                            HStack {
                                Button("Edit") {
                                    onEdit()
                                }
                                .buttonStyle(.bordered)
                                
                                Spacer()
                                
                                Button("Open in Browser") {
                                    UIApplication.shared.open(url)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                            .padding(.top)
                        }
                        .padding()
                    } else {
                        // Handle URL creation failure if needed
                        Text("Could not create preview URL.")
                            .foregroundColor(.red)
                    }
                } else {
                    VStack {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                            .padding()
                        
                        Text("Select a file to preview")
                            .font(.headline)
                        
                        Text("Choose a file from the Files tab")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                        
                        Button("Go to Files") {
                            onGoToFiles()
                        }
                        .buttonStyle(.bordered)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Preview")
        }
    }
}