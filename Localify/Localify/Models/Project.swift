//
//  Project.swift
//  Localify
//

import Foundation

struct Project: Identifiable, Codable {
    let id: UUID
    var name: String
    var files: [ProjectFile]
    var createdAt: Date
    var updatedAt: Date
    
    struct ProjectFile: Identifiable, Codable {
        let id: UUID
        var name: String
        var type: FileType
        var content: String
        var createdAt: Date
        var updatedAt: Date
        
        enum FileType: String, Codable, CaseIterable {
            case html = "html"
            case css = "css"
            case js = "js"
        }
        
        init(name: String, type: FileType, content: String = "") {
            self.id = UUID()
            self.name = name
            self.type = type
            self.content = content
            self.createdAt = Date()
            self.updatedAt = Date()
        }
    }
    
    init(name: String) {
        self.id = UUID()
        self.name = name
        self.files = []
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    mutating func addFile(_ file: ProjectFile) {
        files.append(file)
        updatedAt = Date()
    }
    
    mutating func updateFile(id: UUID, content: String) {
        if let index = files.firstIndex(where: { $0.id == id }) {
            files[index].content = content
            files[index].updatedAt = Date()
            updatedAt = Date()
        }
    }
    
    mutating func deleteFile(id: UUID) {
        files.removeAll { $0.id == id }
        updatedAt = Date()
    }
}