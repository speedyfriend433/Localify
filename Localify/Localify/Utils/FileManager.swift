//
//  FileManager.swift
//  Localify
//

import Foundation

class LocalifyFileManager {
    static let shared = LocalifyFileManager()
    
    private init() {}
    
    func saveNewFile(fileName: String, fileType: String, content: String) -> URL? {
        guard !fileName.isEmpty else { return nil }
        let finalFileName = fileName.hasSuffix(".(fileType)") ? fileName : "\(fileName).\(fileType)"
        
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsURL.appendingPathComponent(finalFileName)
        
        do {
            try content.data(using: .utf8)?.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save file: \(error)")
            return nil
        }
    }
    
    func saveEditedFile(at fileURL: URL, content: String) -> Bool {
        do {
            try content.data(using: .utf8)?.write(to: fileURL)
            return true
        } catch {
            print("Failed to save edited file: \(error)")
            return false
        }
    }
    
    func loadFileContent(at fileURL: URL) -> String? {
        do {
            return try String(contentsOf: fileURL, encoding: .utf8)
        } catch {
            print("Failed to load file content: \(error)")
            return nil
        }
    }
    
    func importFiles(from urls: [URL]) -> Bool {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        
        var success = true
        for sourceURL in urls {
            let fileName = sourceURL.lastPathComponent
            let destinationURL = documentsURL.appendingPathComponent(fileName)
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            } catch {
                print("Failed to import file \(fileName): \(error)")
                success = false
            }
        }
        
        return success
    }
    
    func loadFiles(withExtensions extensions: [String]) -> [URL] {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return [] }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            return fileURLs.filter { url in
                let fileExtension = url.pathExtension.lowercased()
                return extensions.contains(fileExtension)
            }
        } catch {
            print("Failed to load files: \(error)")
            return []
        }
    }
    
    func deleteFile(at url: URL) -> Bool {
        do {
            try FileManager.default.removeItem(at: url)
            return true
        } catch {
            print("Failed to delete file: \(error)")
            return false
        }
    }
}