//
//  ProjectManager.swift
//  Localify
//

import Foundation

class ProjectManager {
    static let shared = ProjectManager()
    private let fileManager = FileManager.default
    
    internal var projectsURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("Projects")
    }
    
    private init() {
        createProjectsDirectoryIfNeeded()
    }
    
    private func createProjectsDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: projectsURL.path) {
            try? fileManager.createDirectory(at: projectsURL, withIntermediateDirectories: true)
        }
    }
    
    func createProject(name: String) -> Project {
        var project = Project(name: name)
        
        // Create default files
        let htmlFile = Project.ProjectFile(name: "index", type: .html, content: getDefaultTemplate(.html))
        let cssFile = Project.ProjectFile(name: "styles", type: .css, content: getDefaultTemplate(.css))
        let jsFile = Project.ProjectFile(name: "script", type: .js, content: getDefaultTemplate(.js))
        
        project.addFile(htmlFile)
        project.addFile(cssFile)
        project.addFile(jsFile)
        
        saveProject(project)
        return project
    }
    
    func saveProject(_ project: Project) {
        let projectURL = projectsURL.appendingPathComponent(project.id.uuidString)
        
        if !fileManager.fileExists(atPath: projectURL.path) {
            try? fileManager.createDirectory(at: projectURL, withIntermediateDirectories: true)
        }
        
        let projectDataURL = projectURL.appendingPathComponent("project.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let data = try? encoder.encode(project) {
            try? data.write(to: projectDataURL)
        }
        
        // Save individual files
        for file in project.files {
            let fileURL = projectURL.appendingPathComponent(file.name).appendingPathExtension(file.type.rawValue)
            try? file.content.write(to: fileURL, atomically: true, encoding: .utf8)
        }
    }
    
    func loadProjects() -> [Project] {
        guard let urls = try? fileManager.contentsOfDirectory(
            at: projectsURL,
            includingPropertiesForKeys: nil
        ) else { return [] }
        
        return urls.compactMap { url in
            let projectDataURL = url.appendingPathComponent("project.json")
            guard let data = try? Data(contentsOf: projectDataURL),
                  let project = try? JSONDecoder().decode(Project.self, from: data)
            else { return nil }
            return project
        }
    }
    
    func deleteProject(_ project: Project) {
        let projectURL = projectsURL.appendingPathComponent(project.id.uuidString)
        try? fileManager.removeItem(at: projectURL)
    }
    
    func deleteFile(_ file: Project.ProjectFile, from project: inout Project) {
        let fileURL = projectsURL.appendingPathComponent(project.id.uuidString).appendingPathComponent(file.id.uuidString)
        if LocalifyFileManager.shared.deleteFile(at: fileURL) {
            project.deleteFile(id: file.id)
        }
    }
    
    private func getDefaultTemplate(_ type: Project.ProjectFile.FileType) -> String {
        switch type {
        case .html:
            return "<!DOCTYPE html>\n<html>\n<head>\n    <meta charset=\"UTF-8\">\n    <meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">\n    <title>New Project</title>\n    <link rel=\"stylesheet\" href=\"styles.css\">\n    <script src=\"script.js\" defer></script>\n</head>\n<body>\n    <h1>Welcome to Your New Project</h1>\n    <p>Start editing your files to build your web project!</p>\n</body>\n</html>"
        case .css:
            return "/* Project Styles */\n\nbody {\n    font-family: Arial, sans-serif;\n    margin: 0;\n    padding: 20px;\n    line-height: 1.6;\n}\n\nh1 {\n    color: #2c3e50;\n    text-align: center;\n}\n\np {\n    color: #34495e;\n    text-align: center;\n}"
        case .js:
            return "// Project JavaScript\n\ndocument.addEventListener('DOMContentLoaded', () => {\n    console.log('Project initialized!');\n    \n    // Add your JavaScript code here\n});"
        }
    }
}