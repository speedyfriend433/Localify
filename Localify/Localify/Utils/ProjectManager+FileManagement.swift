//
//  ProjectManager+FileManagement.swift
//  Localify
//

import Foundation

extension ProjectManager {
    func addFile(_ file: Project.ProjectFile, to project: Project) {
        var updatedProject = project
        updatedProject.addFile(file)
        saveProject(updatedProject)
    }
    
    func updateFile(_ file: Project.ProjectFile, in project: Project) {
        var updatedProject = project
        updatedProject.updateFile(id: file.id, content: file.content)
        saveProject(updatedProject)
    }
    
    func loadProject(id: UUID) -> Project? {
        let projectURL = projectsURL.appendingPathComponent(id.uuidString)
        let projectDataURL = projectURL.appendingPathComponent("project.json")
        
        guard let data = try? Data(contentsOf: projectDataURL),
              let project = try? JSONDecoder().decode(Project.self, from: data)
        else { return nil }
        
        return project
    }
}