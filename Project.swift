import ProjectDescription

let project = Project(
  name: "SoundboardClip",
  targets: [
    .target(
      name: "SoundboardClip",
      destinations: .iOS,
      product: .app,
      bundleId: "io.assanee.SoundboardClip",
      infoPlist: .extendingDefault(
        with: [
          "UILaunchScreen": [:]
        ]
      ),
      sources: ["SoundboardClip/Sources/**"],
      resources: ["SoundboardClip/Resources/**"],
      dependencies: [.external(name: "YouTubePlayerKit")],
      settings: .settings(
        base: [
          "ENABLE_USER_SCRIPT_SANDBOXING": "YES",
          "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
          "ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOL_FRAMEWORKS": "YES",
        ]
      )
    ),
    .target(
      name: "SoundboardClipTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "io.assanee.SoundboardClipTests",
      infoPlist: .default,
      sources: ["SoundboardClip/Tests/**"],
      resources: [],
      dependencies: [.target(name: "SoundboardClip")]
    ),
  ]
)
