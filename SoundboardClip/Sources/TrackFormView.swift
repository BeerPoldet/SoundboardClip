import SwiftUI
import YouTubePlayerKit

struct TrackFormView: View {
  @State var path = NavigationPath()
  @State var youtubeURLString: String = ""
  @FocusState var focus: Field?
  @State var youtubePlayer: YouTubePlayer? = nil
  @State var title: String = ""
  @State var playEndsInSecond: Int? = 5
  @State var videoInfo: YouTubeVideoInfo? = nil

  var onCancel: (() -> Void)? = nil
  var onSave: ((Track) -> Void)? = nil

  var isNextDisabled: Bool {
    videoInfo == nil
  }

  var isSaveDisabled: Bool {
    isNextDisabled || title.isEmpty
  }

  enum Path: Hashable {
    case preview(info: YouTubeVideoInfo)
  }

  enum Field {
    case url
  }

  var body: some View {
    NavigationStack(path: $path) {
      Form {
        TextField(
          "YouTube URL",
          text: $youtubeURLString
        )
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
        .keyboardType(.URL)
        .fontDesign(.rounded)
        .focused($focus, equals: .url)
        .submitLabel(.next)
        .onChange(of: youtubeURLString) { _, _ in
          onYouTubeURLChanged()
        }
        .onSubmit {
          done()
        }
      }
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            onCancel?()
          } label: {
            Text("Cancel")
          }
        }

        ToolbarItem(placement: .automatic) {
          Button {
            done()
          } label: {
            Text("Next")
          }
          .disabled(isNextDisabled)
        }

        ToolbarItem(placement: .keyboard) {
          HStack {
            Spacer()

            Button {
              done()
            } label: {
              Image(systemName: "arrow.up.circle.fill")
                .font(.title3)
            }
            .disabled(isNextDisabled)
          }
        }
      }
      .onAppear {
        focus = .url
      }
      .navigationDestination(for: Path.self) { path in
        switch path {
        case let .preview(info):
          YouTubePreviewView(
            info: info,
            title: $title,
            playEndsInSecond: $playEndsInSecond
          )
          .navigationTitle("Preview")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .automatic) {
              Button {
                if let onSave {
                  onSave(
                    Track(
                      id: info.id,
                      startTime: info.startTime,
                      endTime: playEndsInSecond.map {
                        (info.startTime ?? 0) + Double($0)
                      },
                      thumbnailURL: YouTubeVideoThumbnail(videoID: info.id).url,
                      title: title.trimmingCharacters(in: .whitespacesAndNewlines)
                    )
                  )
                }
              } label: {
                Text("Save")
              }
              .disabled(isSaveDisabled)
            }
          }
        }
      }
    }
  }

  func onYouTubeURLChanged() {
    videoInfo = YouTubeVideoInfo(urlString: youtubeURLString)
  }

  func done() {
    focus = nil
    guard path.isEmpty, let info = videoInfo else { return }
    path.append(Path.preview(info: info))
  }

  func onCancel(_ onCancel: (() -> Void)?) -> Self {
    var view = self
    view.onCancel = onCancel
    return view
  }

  func onSave(_ onSave: ((Track) -> Void)?) -> Self {
    var view = self
    view.onSave = onSave
    return view
  }
}

extension String {
  func isValidYouTubeURL() -> Bool {
    let patterns = [
      /^https?:\/\/(?:www\.)?youtube\.com\/watch\?v=[\w-]{11}(?:\S+)?$/,  // youtube.com/watch?v=
      /^https?:\/\/(?:www\.)?youtube\.com\/embed\/[\w-]{11}(?:\S+)?$/,  // youtube.com/embed/
      /^https?:\/\/(?:www\.)?youtube\.com\/v\/[\w-]{11}(?:\S+)?$/,  // youtube.com/v/
      /^https?:\/\/(?:www\.)?youtu\.be\/[\w-]{11}(?:\S+)?$/,  // youtu.be/
    ]

    return patterns.contains { pattern in
      self.wholeMatch(of: pattern) != nil
    }
  }
}

struct YouTubeVideoInfo: Hashable {
  let id: String
  let startTime: Double?
}

extension YouTubeVideoInfo {
  init?(urlString: String) {
    guard
      let url = URL(string: urlString),
      let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
      let videoId = Self.getVideoID(urlString: urlString)
    else {
      return nil
    }

    let startTime = components
      .queryItems?
      .first(where: { $0.name == "t" })?
      .value.flatMap { Double($0) }

    self = YouTubeVideoInfo(id: videoId, startTime: startTime)
  }

  static func getVideoID(urlString: String) -> String? {
    let patterns: [Regex<(Substring, Substring)>] = [
      /^https?:\/\/(?:www\.)?youtube\.com\/watch\?v=([\w-]{11})(?:\S+)?$/,
      /^https?:\/\/(?:www\.)?youtube\.com\/embed\/([\w-]{11})(?:\S+)?$/,
      /^https?:\/\/(?:www\.)?youtube\.com\/v\/([\w-]{11})(?:\S+)?$/,
      /^https?:\/\/(?:www\.)?youtu\.be\/([\w-]{11})(?:\S+)?$/,
    ]

    // Then try patterns without timestamp
    for pattern in patterns {
      if let match = urlString.wholeMatch(of: pattern) {
        return String(match.1)
      }
    }

    return nil
  }
}

#Preview {
  TrackFormView()
}
