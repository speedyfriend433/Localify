//
//  MainTabView.swift
//  Localify
//

import SwiftUI

struct MainTabView: View {
    let serverURL: String
    let fileTypes: [String]
    @Binding var projects: [Project]
    @Binding var selectedProject: Project?
    @Binding var selectedFile: Project.ProjectFile?
    @Binding var selectedTab: Int
    @Binding var showNewProjectSheet: Bool
    @Binding var showEditFileSheet: Bool
    @Binding var editFileContent: String
    @Binding var showNewFileSheet: Bool
    @Binding var showDocumentPicker: Bool
    var deleteProject: (Project) -> Void
    let onAppear: () -> Void
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Server Tab
            ServerTabView(serverURL: serverURL, fileTypes: fileTypes)
                .tabItem {
                    Label("Server", systemImage: "server.rack")
                }
                .tag(0)
            
            // Projects Tab
            NavigationView {
                ProjectListView(
                    projects: projects,
                    selectedProject: selectedProject,
                    onProjectSelect: { project in
                        selectedProject = project
                        selectedTab = 2 // Switch to preview tab
                    },
                    onNewProject: { 
                        showNewProjectSheet = true 
                    },
                    onDeleteProject: deleteProject
                )
                .sheet(isPresented: $showNewProjectSheet) {
                    ProjectCreationView(
                        showNewProjectSheet: $showNewProjectSheet,
                        onCreate: { name in
                            let project = ProjectManager.shared.createProject(name: name)
                            selectedProject = project
                            projects = ProjectManager.shared.loadProjects()
                        }
                    )
                }
            }
            .tabItem {
                Label("Projects", systemImage: "folder")
            }
            .tag(1)
            
            // Files Tab
            NavigationView {
                if let project = selectedProject {
                    FilesTabView(
                        files: project.files.map { URL(fileURLWithPath: "\(project.id)/\($0.name).\($0.type.rawValue)") },
                        selectedFileURL: selectedFile != nil ? URL(fileURLWithPath: "\(project.id)/\(selectedFile!.name).\(selectedFile!.type.rawValue)") : nil,
                        fileTypes: fileTypes,
                        onFileSelect: { url in
                            let fileName = url.deletingPathExtension().lastPathComponent
                            let fileType = url.pathExtension.lowercased()
                            if let file = project.files.first(where: { 
                                $0.name == fileName && $0.type.rawValue == fileType
                            }) {
                                selectedFile = file
                                editFileContent = file.content
                                selectedTab = 3 // Switch to preview tab
                            }
                        },
                        onFileEdit: { url in
                            let fileName = url.deletingPathExtension().lastPathComponent
                            let fileType = url.pathExtension.lowercased()
                            if let file = project.files.first(where: { 
                                $0.name == fileName && $0.type.rawValue == fileType
                            }) {
                                selectedFile = file
                                editFileContent = file.content
                                showEditFileSheet = true
                            }
                        },
                        onNewFile: { 
                            showNewFileSheet = true
                        },
                        onImportFile: { 
                            showDocumentPicker = true
                        },
                        onRefresh: { 
                            if let project = selectedProject {
                                selectedProject = ProjectManager.shared.loadProject(id: project.id)
                            }
                        },
                        onDelete: { indexSet in
                            if let project = selectedProject {
                                indexSet.forEach { index in
                                    let file = project.files[index]
                                    if var project = selectedProject {
                                        ProjectManager.shared.deleteFile(file, from: &project)
                                    }
                                }
                                if let project = selectedProject {
                                    selectedProject = ProjectManager.shared.loadProject(id: project.id)
                                }
                            }
                        }
                    )
                } else {
                    Text("Select a project to view its files")
                        .foregroundColor(.secondary)
                }
            }
            .tabItem {
                Label("Files", systemImage: "doc.text")
            }
            .tag(2)
            
            // Preview Tab
            NavigationView {
                if let project = selectedProject, let file = selectedFile,
                   let url = URL(string: "\(serverURL)projects/\(project.id.uuidString)/\(file.name).\(file.type.rawValue)") {
                    VStack {
                        Text(file.name)
                            .font(.headline)
                            .padding(.bottom, 4)
                        
                        WebView(url: url)
                            .cornerRadius(10)
                        
                        HStack {
                            Button("Edit") {
                                editFileContent = file.content
                                showEditFileSheet = true
                            }
                            .buttonStyle(.bordered)
                            
                            Spacer()
                            
                            Button("Open in Browser") {
                                // Ensure the URL is correctly formatted before opening
                                if let browserUrl = URL(string: "\(serverURL)projects/\(project.id.uuidString)/\(file.name).\(file.type.rawValue)") {
                                    UIApplication.shared.open(browserUrl)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(.top)
                    }
                    .padding()
                } else {
                    Text("Select a file to preview")
                        .foregroundColor(.secondary)
                }
            }
            .tabItem {
                Label("Preview", systemImage: "eye")
            }
            .tag(3)
        }
        .onAppear {
            onAppear()
        }
    }
}