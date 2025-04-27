//
//  ServerManager.swift
//  Localify
//

import Foundation
import Swifter

class ServerManager {
    static let shared = ServerManager()
    
    private var server: HttpServer?
    private(set) var serverURL: String = ""
    
    private init() {}
    
    func startServer() -> Bool {
        let server = HttpServer()
        server["/"] = { _ in
            .ok(.htmlBody("Hello from Swifter!"))
        }
        
        // Serve project files from the Projects directory within Documents
        let projectsPath = ProjectManager.shared.projectsURL.path
        server["/projects/:project_id/:file_name"] = { request in
            guard let projectId = request.params[":project_id"],
                  let fileName = request.params[":file_name"] else {
                return .badRequest(.text("Missing project ID or file name"))
            }
            
            let filePath = projectsPath + "/" + projectId + "/" + fileName
            
            if FileManager.default.fileExists(atPath: filePath) {
                // Determine MIME type based on file extension
                let fileExtension = URL(fileURLWithPath: fileName).pathExtension.lowercased()
                var mimeType = "application/octet-stream" // Default
                switch fileExtension {
                case "html", "htm": mimeType = "text/html"
                case "css": mimeType = "text/css"
                case "js": mimeType = "application/javascript"
                // Add more MIME types as needed
                default: break
                }
                
                // Use shareFile to correctly handle headers and potential errors
                return shareFile(filePath)(request)
            } else {
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
            return true
        } catch {
            self.serverURL = "Failed to start server: \(error)"
            return false
        }
    }
    
    func stopServer() {
        server?.stop()
        server = nil
        serverURL = ""
    }
    
    // Helper to get device's WiFi IP address
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