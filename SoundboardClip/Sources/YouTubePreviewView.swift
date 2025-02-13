import SwiftUI
import YouTubePlayerKit

struct YouTubePreviewView: View {
  let info: YouTubeVideoInfo
  @State var player: YouTubePlayer

  let playEndInSecondOptions = [5, 10, 15, 30]
  @Binding var title: String
  @Binding var playEndsInSecond: Int?

  init(info: YouTubeVideoInfo, title: Binding<String>, playEndsInSecond: Binding<Int?>) {
    self.info = info
    self._title = title
    self._playEndsInSecond = playEndsInSecond
    self.player = YouTubePlayer(source: .video(id: info.id))
    player.parameters.startTime = info.startTime.map {
      Measurement(value: Double($0), unit: .seconds)
    }
    player.parameters.autoPlay = true
    player.parameters.endTime =
      getPlayerEndTime(player: player, playEndsInSecond: playEndsInSecond.wrappedValue) ?? nil
  }

  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()

      VStack {
        ZStack {
          ProgressView()
          YouTubePlayerView(player) { state in
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
          Color.clear
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.bottom)

        Divider()

        VStack {
          TextField("Title", text: $title)
            .padding(.vertical, 5)

          Divider()

          HStack {
            Text("Ends In")
            Spacer()
            Picker("Ends In", selection: $playEndsInSecond) {
              Text("Never").tag(Optional<Int>.none)

              ForEach(playEndInSecondOptions, id: \.self) {
                Text("\($0)s").tag(Optional<Int>.some($0))
              }
            }
            .onChange(of: playEndsInSecond) { _, newValue in
              onPlayEndsChanged()
            }
          }
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
        .background(Color.secondary.opacity(0.2).clipShape(RoundedRectangle(cornerRadius: 10)))
        .padding()

        //          Form {
        //            TextField("Title", text: $title)
        //
        //            Picker("Ends In", selection: $playEndsInSecond) {
        //              Text("Never").tag(Optional<Int>.none)
        //
        //              ForEach(playEndInSecondOptions, id: \.self) {
        //                Text("\($0)").tag($0)
        //              }
        //            }
        //          }
        //        .frame(maxWidth: .infinity, maxHeight: 200)
      }
    }
    .colorScheme(.dark)
  }

  func onPlayEndsChanged() {
    player.parameters.endTime =
      getPlayerEndTime(player: player, playEndsInSecond: playEndsInSecond) ?? nil
  }
}

@MainActor
func getPlayerEndTime(player: YouTubePlayer, playEndsInSecond: Int?) -> Measurement<UnitDuration>? {
  guard let playEndsInSecond else { return nil }
  let startTime = player.parameters.startTime?.value ?? 0
  return Measurement(
    value: Double(playEndsInSecond) + startTime,
    unit: .seconds
  )
}

#Preview {
  @Previewable @State var title: String = "Depression"
  @Previewable @State var playsEndsInSecond: Int? = 10

  YouTubePreviewView(
    info: YouTubeVideoInfo(id: "QowrW0Qj1og", startTime: 4),
    title: $title,
    playEndsInSecond: $playsEndsInSecond
  )
}
