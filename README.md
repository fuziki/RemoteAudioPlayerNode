# RemoteAudioPlayerNode

![Platform](https://img.shields.io/badge/platform-%20iOS%20-lightgrey.svg)
![Swift](https://img.shields.io/badge/swift-green.svg)
![Xode](https://img.shields.io/badge/xcode-xcode12-green.svg)

AVAudioNode for playing Remote Audio Files.

# Required
* Xcode 12

# Installation
## Swift Package Manager

```
https://github.com/fuziki/RemoteAudioPlayerNode
```

# Usage
## Play Remote Audio File

* Make RemoteAudioPlayerNode instance.
* Schedule remote audio file with url.

```siwft
private let player = RemoteAudioPlayerNode()

// ~ Setup Audio Engine ~

player.scheduleRemoteFile(URL(string: "http://www.ne.jp/asahi/music/myuu/wave/fanfare.mp3")!, completionHandler: {
    print("finish play!")
})
```

# Example
## Example Server

* Run example server

```
make run-example-server
```

* Check example server

```
make curl-request EXPECT=3
```

## Example Client App

* Open RemoteAudioPlayerNode.xcworkspace
* Run "ClientApp"
