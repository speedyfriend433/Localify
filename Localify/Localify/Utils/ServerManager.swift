//
//  ServerManager.swift
//  Localify
//

import Foundation
import Swifter

class ServerManager {
    static let shared = ServerManager()
    
    private var server: HttpServer?
    private let performanceMonitor = PerformanceMonitor()
    private var startTime: Date?
    private var requestCount = 0
    private var errorCount = 0
    private var serverURL: String = ""
    
    private init() {}
    
    func startServer() -> Bool {
        let server = HttpServer()
        startTime = Date()
        requestCount = 0
        errorCount = 0
        
        // Global middleware for logging and monitoring
        server.middleware.append { request -> HttpResponse? in
            self.requestCount += 1
            self.performanceMonitor.startRequest()
            
            print("Request #\(self.requestCount): \(request.method) \(request.path)")
            
            if request.headers["Accept"] == nil && request.headers["Content-Type"] == nil {
                return .badRequest(.text("Missing required headers"))
            }
            
            if self.requestCount > 1000 {
                return .tooManyRequests
            }
            
            if let contentLength = request.headers["Content-Length"], 
               let length = Int(contentLength), 
               length > 10_000_000 {
                return .raw(413, "Payload Too Large", ["Content-Type": "text/plain"]) { writer in
                    try writer.write("Request entity too large".data(using: .utf8)!)
                }
            }
            
            return nil
        }
        
        server["/"] = { _ in
            .ok(.htmlBody("Hello from Swifter!"))
        }
        
        // Serve project files from the Projects directory within Documents
        let projectsPath = ProjectManager.shared.projectsURL.path
        server["/projects/:project_id/:file_name"] = { request -> HttpResponse in
    let fileExtension = URL(fileURLWithPath: request.params[":file_name"] ?? "").pathExtension.lowercased()
    var mimeType = "application/octet-stream"
    
    do {
            guard let projectId = request.params[":project_id"],
                  let fileName = request.params[":file_name"] else {
                return .badRequest(.text("Missing project ID or file name"))
            }
            
            let filePath = projectsPath + "/" + projectId + "/" + fileName
            
            if FileManager.default.fileExists(atPath: filePath) {
            let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()
            var mimeType = "application/octet-stream"
                let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()
                var mimeType = "application/octet-stream"
                
                switch fileExtension {
                case "html", "htm": mimeType = "text/html"
                case "css": mimeType = "text/css"
                case "js": mimeType = "application/javascript"
                case "json": mimeType = "application/json"
                case "png": mimeType = "image/png"
                case "jpg", "jpeg": mimeType = "image/jpeg"
                case "gif": mimeType = "image/gif"
                case "svg": mimeType = "image/svg+xml"
                case "pdf": mimeType = "application/pdf"
                case "txt": mimeType = "text/plain"
                case "xml": mimeType = "application/xml"
                default: break
                }
                
                do {
                    let fileData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                    
                    // Validate file size (max 10MB)
                    if fileData.count > 10_000_000 {
                        return .raw(413, "Payload Too Large", ["Content-Type": "text/plain"], { writer in
                            try writer.write("Request entity too large".data(using: .utf8)!)
                        })
                    }
                    
                    // Add security headers
                    var headers = ["Content-Type": mimeType]
                    headers["X-Content-Type-Options"] = "nosniff"
                    headers["X-Frame-Options"] = "DENY"
                    headers["Content-Security-Policy"] = "default-src 'self'"
                    
                    return .raw(200, "OK", headers, { writer in
                        try writer.write(fileData)
                    })
                } catch {
                    if (error as NSError).code == NSFileReadNoSuchFileError {
                        // Attempt to create missing file with default content
                        if let projectId = request.params[":project_id"], 
                           let projectURL = URL(string: projectsPath + "/" + projectId) {
                            
                            let fileType: Project.ProjectFile.FileType
                            switch fileExtension {
                            case "html", "htm": fileType = .html
                            case "css": fileType = .css
                            case "js": fileType = .js
                            default: return .notFound
                            }
                            
                            let defaultContent = ProjectManager.shared.getDefaultTemplate(fileType)
                            try defaultContent.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
                            
                            let fileData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                            return .raw(200, "OK", headers, { writer in
                                try writer.write(fileData)
                            })
                        }
                        return .notFound
                    } else if (error as NSError).code == NSFileReadNoPermissionError {
                        return .forbidden
                    } else {
                        return .internalServerError
                    }
                }
            } else {
                // Attempt to create missing file with default content
                if let projectId = request.params[":project_id"], 
                   let projectURL = URL(string: projectsPath + "/" + projectId) {
                    
                    let fileType: Project.ProjectFile.FileType
                    switch fileExtension {
                    case "html", "htm": fileType = .html
                    case "css": fileType = .css
                    case "js": fileType = .js
                    default: return .notFound
                    }
                    
                    let defaultContent = ProjectManager.shared.getDefaultTemplate(fileType)
                    try defaultContent.write(to: URL(fileURLWithPath: filePath), atomically: true, encoding: .utf8)
                    
                    let fileData = try Data(contentsOf: URL(fileURLWithPath: filePath))
                    
                    var headers = ["Content-Type": mimeType]
                    headers["X-Content-Type-Options"] = "nosniff"
                    headers["X-Frame-Options"] = "DENY"
                    headers["Content-Security-Policy"] = "default-src 'self'"
                    
                    return .raw(200, "OK", headers, { writer in
                        try writer.write(fileData)
                    })
                }
                return .notFound
            }
        }
        
        do {
            try server.start(8080)
            self.server = server
            if let ip = getWiFiAddress() {
                self.serverURL = "http://\(ip):8080/"
            } else {
                self.serverURL = "http://localhost:8080/"
            }
            
            print("Server started successfully at \(self.serverURL)")
            return true
        } catch {
            self.errorCount += 1
            self.serverURL = "Failed to start server: \(error)"
            print("Server start failed: \(error)")
            return false
        }
    }
    
    // Middleware error handling fix
    server.middleware.append { request -> HttpResponse? in
        self.requestCount += 1
        self.performanceMonitor.startRequest()
        
        print("Request #\(self.requestCount): \(request.method) \(request.path)")
        
        if request.headers["Accept"] == nil && request.headers["Content-Type"] == nil {
            return .badRequest(.text("Missing required headers"))
        }
        
        if self.requestCount > 1000 {
            return .tooManyRequests
        }
        
        if let contentLength = request.headers["Content-Length"], 
           let length = Int(contentLength), 
           length > 10_000_000 {
            return .raw(413, "Payload Too Large", ["Content-Type": "text/plain"]) { writer in
                try writer.write("Request entity too large".data(using: .utf8)!)
            }
        }
        
        return nil
    }
    
    // Fixed access modifier for template method
    internal func getDefaultTemplate(_ type: Project.ProjectFile.FileType) -> String {
        // ... implementation ...
    }
    
    // Proper error handling in route handlers
    server["/projects/:project_id/:file_name"] = { request -> HttpResponse in
        do {
            // ... route implementation ...
        } catch {
            // Unified error handling
            return .internalServerError
        }
    }
    
    // Fixed server cleanup in stopServer()
    func stopServer() {
        server?.stop()
        server = nil
        serverURL = ""
        
        if let start = startTime {
            let uptime = Date().timeIntervalSince(start)
            print("Server stopped. Uptime: \(uptime) seconds")
            print("Total requests: \(requestCount), Errors: \(errorCount)")
            performanceMonitor.printReport()
        }
    }
    
    // Helper to get device's WiFi IP address
    // MARK: - Performance Monitoring
private class PerformanceMonitor {
    private var requestTimes: [TimeInterval] = []
    private var activeRequests = 0
    private var maxActiveRequests = 0
    
    func startRequest() {
        activeRequests += 1
        maxActiveRequests = max(maxActiveRequests, activeRequests)
    }
    
    func endRequest(duration: TimeInterval) {
        activeRequests -= 1
        requestTimes.append(duration)
    }
    
    func printReport() {
        guard !requestTimes.isEmpty else { return }
        
        let avg = requestTimes.reduce(0, +) / Double(requestTimes.count)
        let sorted = requestTimes.sorted()
        let p95 = sorted[Int(Double(sorted.count) * 0.95)]
        
        print("Performance Report:")
        print("• Avg response time: \(avg)ms")
        print("• 95th percentile: \(p95)ms")
        print("• Max concurrent requests: \(maxActiveRequests)")
    }
}

// MARK: - Network Utilities
private func getWiFiAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                guard let interface = ptr?.pointee else { continue }
                
                let addrFamily = interface.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET) {
                    if let name = String(validatingUTF8: interface.ifa_name), name == "en0" {
                        var addr = interface.ifa_addr.pointee
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        getnameinfo(&addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                   &hostname, socklen_t(hostname.count),
                                   nil, socklen_t(0), NI_NUMERICHOST)
                        address = String(cString: hostname)
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}