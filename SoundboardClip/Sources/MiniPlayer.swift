import SwiftUI
import YouTubePlayerKit

struct MiniPlayer: View {
  let track: Track
  let playDate: Date
  var onClose: (() -> Void)? = nil

  var body: some View {
    VStack {
      Spacer()
      VStack(spacing: 0) {
        Divider()
        VStack(spacing: 15) {
          HStack {
            Text("\(track.title)")
              .font(.body.bold())
              .fontDesign(.rounded)

            Spacer()

            HStack {
              Button {
                onClose?()
              } label: {
                Image(systemName: "xmark")
                  .font(.footnote.bold())
                  .padding(10)
                  .background(Color.secondary.opacity(0.2))
                  .foregroundStyle(.secondary)
              }
              .clipShape(Circle())
            }
          }
          ZStack {
            ProgressView()

            YouTubePlayerView(
              YouTubePlayer(
                source: .video(id: track.id),
                parameters: YouTubePlayer.Parameters(
                  autoPlay: true,
                  startTime: track.startTime.map { Measurement(value: $0, unit: .seconds) },
                  endTime: track.endTime.map { Measurement(value: $0, unit: .seconds) }
                )
              )
            ) { state in
              switch state {
              case .idle, .ready:
                EmptyView()
              case .error(let error):
                ContentUnavailableView(
                  "Error",
                  systemImage: "exclamationmark.triangle.fill",
                  description: Text("YouTube player couldn't be loaded: \(error)")
                )
              }
            }
            .aspectRatio(16 / 9, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .id("\(track.id)_\(playDate)")
          }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
      }
      .background(Color(.systemBackground))
    }
  }

  func onClose(_ onClose: (() -> Void)?) -> MiniPlayer {
    var view = self
    view.onClose = onClose
    return view
  }
}

#Preview {
  MiniPlayer(
    track: Track(
      id: "HsmI_WrAxs8",
      startTime: Optional(2.0),
      endTime: Optional(7.0),
      thumbnailURL: URL(string: "https://img.youtube.com/vi/HsmI_WrAxs8/sddefault.jpg")!,
      title: "Lelolelolelo"
    ),
    playDate: Date()
  )
  .background(Color(.secondarySystemBackground))
}
