//
//  ContentViewModel.swift
//  
//
//  Created by fuziki on 2021/05/17.
//

import AVFoundation
import RemoteAudioPlayerNode

protocol AudioEngineService {
    func play(file: String)
}

class AudioEngineServiceMock: AudioEngineService {
    func play(file: String) { }
}

class DefaultAudioEngineService: AudioEngineService {
    private let engine: AVAudioEngine = AVAudioEngine()
    private let player = RemoteAudioPlayerNode()
    init() {
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        engine.prepare()
        try! engine.start()
        player.play()
    }
    public func play(file: String) {
        player.scheduleRemoteFile(URL(string: file)!, completionHandler: {
            print("finish play!")
        })
    }
}
