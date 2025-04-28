//
//  ContentView.swift
//  Localify
//

import SwiftUI
import Swifter
import WebKit
import UniformTypeIdentifiers
import MobileCoreServices
import UIKit

struct ContentView: View {
    @State private var server: HttpServer? = nil
    @State private var serverURL: String = ""
    @State private var showNewProjectSheet = false
    @State private var showEditFileSheet = false
    @State private var editFileContent = ""
    @State private var projects: [Project] = []
    @State private var selectedProject: Project? = nil
    @State private var selectedFile: Project.ProjectFile? = nil
    @State private var selectedTab = 0
    @State private var showNewFileSheet = false
    @State private var showDocumentPicker = false
    @State private var newFileName = ""
    @State private var newFileType: Project.ProjectFile.FileType = .html
    @State private var newFileContent = ""
    
    let fileTypes = Project.ProjectFile.FileType.allCases
    
    // File templates for quick creation
    let templates = [
        "html": "<!DOCTYPE html>\n<html>\n<head>\n    <meta charset=\"UTF-8\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n    <title>New Page</title>\n</head>\n<body>\n    <h1>Hello World</h1>\n</body>\n</html>",
        "js": "// JavaScript file\n\nconsole.log('Hello from JavaScript!');",
        "css": "/* CSS Styles */\n\nbody {\n    font-family: Arial, sans-serif;\n    margin: 0;\n    padding: 20px;\n}\n\nh1 {\n    color: #333;\n}\n"
    ]

    var body: some View {
        if #available(iOS 17.0, *) {
            MainTabView(
                serverURL: serverURL,
                fileTypes: fileTypes.map { $0.rawValue },
                projects: $projects,
                selectedProject: $selectedProject,
                selectedFile: $selectedFile,
                selectedTab: $selectedTab,
                showNewProjectSheet: $showNewProjectSheet,
                showEditFileSheet: $showEditFileSheet,
                editFileContent: $editFileContent,
                showNewFileSheet: $showNewFileSheet,
                showDocumentPicker: $showDocumentPicker,
                deleteProject: deleteProject,
                onAppear: {
                    startServer()
                    loadProjects()
                    loadFiles()
                }
            )
            .onChange(of: showNewProjectSheet) { _, newValue in
                if !newValue {
                    loadProjects()
                }
            }
            .sheet(isPresented: $showNewFileSheet) {
                NewFileSheetView(
                    newFileName: $newFileName,
                    newFileType: $newFileType,
                    newFileContent: $newFileContent,
                    fileTypes: fileTypes.map { $0.rawValue },
                    templates: templates,
                    onCancel: {
                        showNewFileSheet = false
                        resetNewFileForm()
                    },
                    onSave: {
                        saveNewFile()
                        showNewFileSheet = false
                        resetNewFileForm()
                        loadFiles()
                    }
                )
            }
            .sheet(isPresented: $showEditFileSheet) {
                if let file = selectedFile {
                    EditFileSheetView(
                        fileName: file.name,
                        fileType: file.type,
                        editFileContent: $editFileContent,
                        onCancel: {
                            showEditFileSheet = false
                        },
                        onSave: {
                            saveEditedFile()
                            showEditFileSheet = false
                            loadFiles()
                        }
                    )
                } else {
                    EmptyView()
                }
            }
            .onChange(of: selectedFile) { _, newFile in
                if let file = newFile {
                    editFileContent = file.content
                }
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(fileTypes: fileTypes.map { $0.rawValue }) { urls in
                    importFiles(from: urls)
                }
            }

            .onDisappear {
                stopServer()
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - Server Management
    
    private func startServer() {
        if ServerManager.shared.startServer() {
            self.serverURL = ServerManager.shared.serverURL
        }
    }
    
    private func stopServer() {
        ServerManager.shared.stopServer()
    }
    
    // MARK: - Project Management
    
    private func loadProjects() {
        projects = ProjectManager.shared.loadProjects()
    }
    
    private func deleteProject(_ project: Project) {
        ProjectManager.shared.deleteProject(project)
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects.remove(at: index)
        }
        if selectedProject?.id == project.id {
            selectedProject = nil
            selectedFile = nil
        }
    }
    
    // MARK: - File Management
    
    private func resetNewFileForm() {
        newFileName = ""
        newFileType = .html
        newFileContent = ""
    }
    
    private func saveNewFile() {
        guard let project = selectedProject else { return }
        let file = Project.ProjectFile(name: newFileName, type: newFileType, content: newFileContent)
        ProjectManager.shared.addFile(file, to: project)
        selectedProject = ProjectManager.shared.loadProject(id: project.id)
    }
    
    private func saveEditedFile() {
        guard let project = selectedProject, let file = selectedFile else { return }
        let updatedFile = Project.ProjectFile(name: file.name, type: file.type, content: editFileContent)
        ProjectManager.shared.updateFile(updatedFile, in: project)
        selectedProject = ProjectManager.shared.loadProject(id: project.id)
        selectedFile = updatedFile
    }
    
    private func loadFileContent() {
        guard let file = selectedFile else { return }
        editFileContent = file.content
    }
    
    private func loadFiles() {
        if let project = selectedProject {
            selectedProject = ProjectManager.shared.loadProject(id: project.id)
        }
    }
    
    private func importFiles(from urls: [URL]) {
        guard let project = selectedProject else { return }
        for url in urls {
            guard let fileType = Project.ProjectFile.FileType(rawValue: url.pathExtension.lowercased()) else { continue }
            guard let content = try? String(contentsOf: url, encoding: .utf8) else { continue }
            let fileName = url.deletingPathExtension().lastPathComponent
            let file = Project.ProjectFile(name: fileName, type: fileType, content: content)
            ProjectManager.shared.addFile(file, to: project)
        }
        selectedProject = ProjectManager.shared.loadProject(id: project.id)
    }
}

#Preview {
    ContentView()
}
