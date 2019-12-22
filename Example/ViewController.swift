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
    var engine: AVAudioEngine!
    var player = AVAudioPlayerNode()
    let internalFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 48000, channels: 2, interleaved: false)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        engine = AVAudioEngine()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: internalFormat)
        engine.prepare()
        try! engine.start()
        player.play()
        
        let url = URL(string: "http://www.ne.jp/asahi/music/myuu/wave/fanfare.mp3")!
//        let url = URL(string: "https://cdn.fastlearner.media/the-last-ones.mp3")!
        let request = URLRequest(url: url)
        task = URLSession
            .shared
            .dataTask(with: request,
                      completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
                        guard let data = data else { return }
                        self?.onMusicData(data: data)
        })

        audioFileStreamServices = AudioFileStreamService()
        
        task.resume()
    }

    private func onMusicData(data: Data) {
        print("on music data: \([UInt8](data[0..<100]))...")
        audioFileStreamServices
            .parseBytes(data: data,
                        completeHandler: { [weak self] (audioFormat: AVAudioFormat,
                            packets: [(data: Data, description: AudioStreamPacketDescription)]) in
                            self?.onPackets(audioFormat: audioFormat, packets: packets)
        })
    }
    
    var converter: CompressedBufferConverter? = nil
    private func onPackets(audioFormat: AVAudioFormat, packets: [(data: Data, description: AudioStreamPacketDescription)]) {
        converter = CompressedBufferConverter(srcFormat: audioFormat, dstFormat: internalFormat, packets: packets)
        for _ in 0..<3 {
            playScheduleBuffer()
        }
    }
    
    var counter: Int = 0
    func playScheduleBuffer() {
        if let ret = converter?.read(frames: 1152), ret.frameLength > 0 {
            counter += 1
            player.scheduleBuffer(ret, completionHandler: { [weak self] in
                self?.counter -= 1
                self?.playScheduleBuffer()
            })
        } else {
            if counter == 0 {
                print("finish play! \(counter)")
            }
        }
    }
}

class CompressedBufferConverter {
    private var converter: AVAudioConverter?

    private var srcFormat: AVAudioFormat
    private var dstFormat: AVAudioFormat
    private var packets: [(data: Data, description: AudioStreamPacketDescription)]

    private var index = 0
    private var audioCompressedBuffer: [AVAudioCompressedBuffer] = []

    public init(srcFormat: AVAudioFormat, dstFormat: AVAudioFormat, packets: [(data: Data, description: AudioStreamPacketDescription)]) {
        self.converter = AVAudioConverter(from: srcFormat, to: dstFormat)
        self.srcFormat = srcFormat
        self.dstFormat = dstFormat
        self.packets = packets
        self.index = 0
        self.audioCompressedBuffer = packets.compactMap({ (data: Data, description: AudioStreamPacketDescription) in
            let compBuff = AVAudioCompressedBuffer(format: srcFormat, packetCapacity: 1, maximumPacketSize: Int(data.count))
            _ = data.withUnsafeBytes({ (ptr: UnsafeRawBufferPointer) in
                memcpy(compBuff.data, ptr.baseAddress!, data.count)
            })
            compBuff.packetDescriptions?.pointee =
                AudioStreamPacketDescription(mStartOffset: 0, mVariableFramesInPacket: 0, mDataByteSize: UInt32(data.count))
            compBuff.packetCount = 1
            compBuff.byteLength = UInt32(data.count)
            return compBuff
        })
    }

    public func read(frames: AVAudioFrameCount) -> AVAudioPCMBuffer? {
        guard let converter = self.converter else {
            return nil
        }
        let pcmBuff = AVAudioPCMBuffer(pcmFormat: dstFormat, frameCapacity: frames)!
        pcmBuff.frameLength = pcmBuff.frameCapacity

        var error: NSError? = nil
        let status: AVAudioConverterOutputStatus = converter
            .convert(to: pcmBuff, error: &error, withInputFrom:
                { [weak self] (count: AVAudioPacketCount,
                    input: UnsafeMutablePointer<AVAudioConverterInputStatus>) -> AVAudioBuffer? in
                    guard let self = self else {
                        input.pointee = .noDataNow
                        return nil
                    }
                    if self.index >= self.audioCompressedBuffer.count {
                        input.pointee = .endOfStream
                        return nil
                    }
                    input.pointee = .haveData
                    let buff = self.audioCompressedBuffer[self.index]
                    self.index += 1
                    return buff
        })
        if status == .error || error != nil { return nil }
        return pcmBuff
    }
}
