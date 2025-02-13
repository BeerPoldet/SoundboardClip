import SwiftData
import SwiftUI
import YouTubePlayerKit

struct SoundBoardView: View {
  @Environment(\.modelContext) var modelContext
  @State var isCreateTrackSheetPresented: Bool = false
  @Query(sort: [SortDescriptor(\Track.createdAt, order: .reverse)]) var tracks: [Track]
  @State var track: Track? = nil

  let columns = [
    GridItem(.flexible(), spacing: 5, alignment: .center),
    GridItem(.flexible(), spacing: 10, alignment: .center),
  ]

  var body: some View {
    NavigationStack {
      ZStack {
        if tracks.isEmpty {
          VStack {
            ContentUnavailableView {
              Label("No Tracks", systemImage: "waveform.path")
            } description: {
              Text("Let's spice things up with your first soundboard's track from a YouTube video.")
            } actions: {
              Button {
                isCreateTrackSheetPresented = true
              } label: {
                Label("Add Track", systemImage: "waveform.badge.plus")
              }
              .buttonStyle(.borderedProminent)

              Button {
                insertRecommendedTracks()
              } label: {
                Text("Add Recommended Tracks")
              }
            }
          }
        } else {
          ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 5) {
              ForEach(tracks) { track in
                Button {
                  withAnimation {
                    self.track = track
                  }
                } label: {
                  ZStack {
                    Color.black

                    AsyncImage(url: track.thumbnailURL) { phase in
                      switch phase {
                      case .empty:
                        if track.thumbnailURL == nil {
                          VStack {
                            Spacer()
                            PlaceholderImage()
                            Spacer()
                          }
                        } else {
                          ProgressView()
                        }
                      case .failure:
                        PlaceholderImage()
                      case let .success(image):
                        image
                          .resizable()
                          .aspectRatio(contentMode: .fill)
                      @unknown default:
                        EmptyView()
                      }
                    }
                    .frame(
                      minWidth: 0,
                      maxWidth: .infinity,
                      minHeight: 0,
                      maxHeight: .infinity
                    )
                    .aspectRatio(1, contentMode: .fit)

                    VStack {
                      Spacer()

                      Text(track.title)
                        .foregroundStyle(.background)
                        .font(.footnote.bold())
                        .fontDesign(.rounded)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 3)
                  }
                  .clipShape(RoundedRectangle(cornerRadius: 10))
                }
              }
            }
            .animation(.default, value: tracks)
          }
          .contentMargins(.horizontal, 5)
        }

        if let track {
          VStack {
            Spacer()
            ZStack {
              Color(.systemBackground)
                .ignoresSafeArea()

              VStack(spacing: 0) {
                Divider()

                HStack(spacing: 10) {
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
                        // EmptyView()
                        Color.white
                          .opacity(0.01)
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
                    .id(track.id)
                  }

                  Text("\(track.title)")
                    .font(.body.bold())
                    .fontDesign(.rounded)

                  Spacer()

                  HStack {
                    Button {
                      withAnimation {
                        self.track = nil
                      }
                    } label: {
                      Image(systemName: "xmark")
                        .font(.body.bold())
                    }
                  }
                  .padding(.vertical)
                  .padding(.leading, 10)
                  .padding(.trailing, 20)
                }
                .padding(10)
              }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 100)
          }
          .transition(.move(edge: .bottom).combined(with: .opacity))
        }
      }
      .toolbar {
        ToolbarItem(placement: .automatic) {
          Button {
            isCreateTrackSheetPresented = true
          } label: {
            Image(systemName: "waveform.badge.plus")
          }
        }
      }
      .sheet(isPresented: $isCreateTrackSheetPresented) {
        TrackFormView()
          .onCancel {
            isCreateTrackSheetPresented = false
          }
          .onSave { track in
            isCreateTrackSheetPresented = false
            dump(track)
            modelContext.insert(track)
          }
      }
    }
  }

  func insertRecommendedTracks() {
    let tracks = [
      Track(
        id: "QowrW0Qj1og",
        startTime: Optional(4.0),
        endTime: Optional(24.0),
        thumbnailURL: URL(string: "https://img.youtube.com/vi/QowrW0Qj1og/sddefault.jpg")!,
        title: "Sad Truth Revealed"
      ),

      Track(
        id: "hRok6zPZKMA",
        startTime: Optional(242.0),
        endTime: Optional(262.0),
        thumbnailURL: URL(string: "https://img.youtube.com/vi/hRok6zPZKMA/sddefault.jpg")!,
        title: "Epic"
      ),

      Track(
        id: "HsmI_WrAxs8",
        startTime: Optional(2.0),
        endTime: Optional(7.0),
        thumbnailURL: URL(string: "https://img.youtube.com/vi/HsmI_WrAxs8/sddefault.jpg")!,
        title: "Lelolelolelo"
      ),
    ]

    for track in tracks {
      modelContext.insert(track)
    }
  }
}

#Preview {
  let config = ModelConfiguration(isStoredInMemoryOnly: true)
  let container = try! ModelContainer(for: Track.self, configurations: config)

  let tracks = [
    Track(
      id: "QowrW0Qj1og",
      startTime: Optional(4.0),
      endTime: Optional(9.0),
      thumbnailURL: URL(string: "https://img.youtube.com/vi/QowrW0Qj1og/sddefault.jpg")!,
      title: "Sad Truth Revealed"
    ),

    Track(
      id: "hRok6zPZKMA",
      startTime: Optional(242.0),
      endTime: Optional(262.0),
      thumbnailURL: URL(string: "https://img.youtube.com/vi/hRok6zPZKMA/sddefault.jpg")!,
      title: "Epic"
    ),

    Track(
      id: "HsmI_WrAxs8",
      startTime: Optional(2.0),
      endTime: Optional(7.0),
      thumbnailURL: URL(string: "https://img.youtube.com/vi/HsmI_WrAxs8/sddefault.jpg")!,
      title: "Lelolelolelo"
    ),

    Track(
      id: "Crb4PWglCvo",
      startTime: Optional(4.0),
      endTime: Optional(9.0),
      thumbnailURL: URL(string: "https://img.youtube.com/vi/Crb4PWglCvo/sddefault.jpg")!,
      title: "B"
    ),
  ]

  for track in tracks {
    // container.mainContext.insert(track)
  }

  return SoundBoardView()
    .modelContainer(container)
}
