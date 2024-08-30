import Foundation
import Photos

class PathUtils {
    static func getRecordPath() -> URL? {
        if let moviesDir = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first {
            let folderUrl = moviesDir.appendingPathComponent("RootEncoder")
            do {
                try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
                return folderUrl
            } catch {
                print("Error creating directory: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
}
