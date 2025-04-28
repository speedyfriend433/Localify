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
    
    func updateFile(_ file: Project.ProjectFile, in project: Project, versionComment: String? = nil) {
        var updatedProject = project
        updatedProject.updateFile(id: file.id, content: file.content, versionComment: versionComment)
        saveProject(updatedProject)
    }
    
    func getFileVersions(fileId: UUID, projectId: UUID) -> [Project.ProjectFile.FileVersion]? {
        guard let project = loadProject(id: projectId),
              let file = project.files.first(where: { $0.id == fileId }) else {
            return nil
        }
        return file.versions
    }
    
    func restoreFileVersion(fileId: UUID, versionId: UUID, projectId: UUID) -> Bool {
        guard var project = loadProject(id: projectId),
              let fileIndex = project.files.firstIndex(where: { $0.id == fileId }),
              let versionIndex = project.files[fileIndex].versions.firstIndex(where: { $0.id == versionId }) else {
            return false
        }
        
        let version = project.files[fileIndex].versions[versionIndex]
        project.files[fileIndex].content = version.content
        project.files[fileIndex].updatedAt = Date()
        project.updatedAt = Date()
        saveProject(project)
        return true
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