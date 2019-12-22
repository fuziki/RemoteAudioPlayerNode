//
//  ViewController.swift
//  Example
//
//  Created by fuziki on 2019/12/16.
//  Copyright © 2019 fuziki.factory. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    var task: URLSessionDataTask!
    var audioFileStreamServices: AudioFileStreamService!
    var engine: AVAudioEngine = AVAudioEngine()
    var player = RemoteAudioPlayerNode()
    let internalFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 2, interleaved: false)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: internalFormat)
        engine.prepare()
        try! engine.start()
        player.play()
        
        player.scheduleRemoteFile(URL(string: "http://www.ne.jp/asahi/music/myuu/wave/fanfare.mp3")!, completionHandler: {
            print("finish play!")
        })
    }
}
