import Foundation

extension String {
    var htmlDecoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        let decoded = try? NSAttributedString(
            data: data,
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
        return decoded?.string ?? self
    }
}
