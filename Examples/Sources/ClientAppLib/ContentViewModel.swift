//
//  ContentViewModel.swift
//  
//
//  Created by fuziki on 2021/05/17.
//

import AVFoundation
import Combine
import RemoteAudioPlayerNode
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var fileList: [String] = []
    
    private let useCase = ContentViewUseCase()
    
    private let engine: AVAudioEngine = AVAudioEngine()
    private let player = RemoteAudioPlayerNode()

    private var cancellables: Set<AnyCancellable> = []
    init() {
        useCase
            .fileListPublisher
            .sink { [weak self] (fileList: [String]) in
                self?.fileList = fileList
            }
            .store(in: &cancellables)
        useCase.fetch()
        
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: nil)
        engine.prepare()
        try! engine.start()
        player.play()

        player.scheduleRemoteFile(URL(string: "http://www.ne.jp/asahi/music/myuu/wave/fanfare.mp3")!, completionHandler: {
            print("finish play!")
        })
    }
}

