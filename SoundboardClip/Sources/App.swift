import SwiftData
import SwiftUI

public struct AppView: View {
  var container: ModelContainer = {
    let schema = Schema([
      Track.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  public var body: some View {
    SoundBoardView()
      .tint(.cyan)
      .modelContainer(container)
  }
}

#Preview {
  AppView()
}
