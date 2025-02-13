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

  init(
    id: String, startTime: Double? = nil, endTime: Double? = nil, thumbnailURL: URL? = nil,
    title: String
  ) {
    self.id = id
    self.startTime = startTime
    self.endTime = endTime
    self.thumbnailURL = thumbnailURL
    self.title = title
  }
}
