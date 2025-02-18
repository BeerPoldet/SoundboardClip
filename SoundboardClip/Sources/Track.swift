import Foundation
import SwiftData

@Model
class Track: Identifiable {
  var id: String
  var startTime: Double?
  var endTime: Double?
  var thumbnailURL: URL?
  var title: String
  var createdAt: Date = Date()
  var updatedAt: Date = Date()

  var url: URL {
    var url = URL(string: "https://youtu.be")!.appendingPathComponent(id)
    if let startTime {
      url.append(queryItems: [URLQueryItem(name: "t", value: "\(Int(startTime))")])
    }
    return url
  }

  init(
    id: String,
    startTime: Double? = nil,
    endTime: Double? = nil,
    thumbnailURL: URL? = nil,
    title: String
  ) {
    self.id = id
    self.startTime = startTime
    self.endTime = endTime
    self.thumbnailURL = thumbnailURL
    self.title = title
  }
}
