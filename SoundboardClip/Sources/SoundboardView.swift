import SwiftData
import SwiftUI
import YouTubePlayerKit

struct SoundBoardView: View {
  @Environment(\.modelContext) var modelContext
  @State var isCreateTrackSheetPresented: Bool = false
  @State var editTrack: Track? = nil
  @Query(sort: [SortDescriptor(\Track.createdAt, order: .reverse)]) var tracks: [Track]
  @State var track: Track? = nil
  //  @State var track: Track? = Track(
  //    id: "HsmI_WrAxs8",
  //    startTime: Optional(2.0),
  //    endTime: Optional(7.0),
  //    thumbnailURL: URL(string: "https://img.youtube.com/vi/HsmI_WrAxs8/sddefault.jpg")!,
  //    title: "Lelolelolelo"
  //  )
  @State var player: YouTubePlayer? = nil
  @State var playDate = Date()

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
                    self.playDate = Date()
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
                .contextMenu {
                  Button {
                    editTrack = track
                  } label: {
                    Label("Edit", systemImage: "pencil")
                  }

                  Divider()

                  Button(role: .destructive) {
                    modelContext.delete(track)
                  } label: {
                    Label("Delete", systemImage: "trash")
                  }
                }
              }
            }
            .animation(.default, value: tracks)
          }
          .contentMargins(.horizontal, 5)
        }

        if let track {
          MiniPlayer(track: track, playDate: playDate)
            .onClose {
              withAnimation {
                self.track = nil
              }
            }
            .transition(.move(edge: .bottom).combined(with: .opacity).animation(.bouncy))
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
      .fullScreenCover(isPresented: $isCreateTrackSheetPresented) {
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
      .fullScreenCover(item: $editTrack) { track in
        TrackFormView(
          youtubeURLString: track.url.absoluteString,
          title: track.title,
          playEndsInSecond: track.endTime.map { Int($0 - (track.startTime ?? 0.0)) },
          videoInfo: YouTubeVideoInfo(id: track.id, startTime: track.startTime)
        )
        .onCancel {
          editTrack = nil
        }
        .onSave { updatedTrack in
          editTrack = nil
          track.id = updatedTrack.id
          track.startTime = updatedTrack.startTime
          track.endTime = updatedTrack.endTime
          track.title = updatedTrack.title
          do {
            try modelContext.save()
          } catch {}
        }
      }
    }
  }

  func insertRecommendedTracks() {
    let tracks = [
      Track(
        id: "QowrW0Qj1og",
        startTime: Optional(4.0),
        endTime: Optional(34.0),
        thumbnailURL: URL(string: "https://img.youtube.com/vi/QowrW0Qj1og/sddefault.jpg")!,
        title: "Sad Truth Revealed"
      ),

      Track(
        id: "hRok6zPZKMA",
        startTime: Optional(242.0),
        endTime: Optional(272.0),
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
      endTime: Optional(34.0),
      thumbnailURL: URL(string: "https://img.youtube.com/vi/QowrW0Qj1og/sddefault.jpg")!,
      title: "Sad Truth Revealed"
    ),

    Track(
      id: "hRok6zPZKMA",
      startTime: Optional(242.0),
      endTime: Optional(272.0),
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
      endTime: Optional(14.0),
      thumbnailURL: URL(string: "https://img.youtube.com/vi/Crb4PWglCvo/sddefault.jpg")!,
      title: "B"
    ),
  ]

  for track in tracks {
    container.mainContext.insert(track)
  }

  return SoundBoardView()
    .modelContainer(container)
}
