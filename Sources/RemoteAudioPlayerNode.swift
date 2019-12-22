//
//  RemoteAudioPlayerNode.swift
//  Example
//
//  Created by fuziki on 2019/12/22.
//  Copyright © 2019 fuziki.factory. All rights reserved.
//

import Foundation
import AVFoundation

public class RemoteAudioPlayerNode: AVAudioPlayerNode {
    private var internalFormat: AVAudioFormat {
        return self.outputFormat(forBus: 0)
    }
    private var audioFileStreamServices: AudioFileStreamService?
    private var downloader: RemoteAudioDownloader = DefaultRemoteAudioDownloader()
    public func set(downloader: RemoteAudioDownloader?) {
        self.downloader = downloader ?? DefaultRemoteAudioDownloader()
    }
    private var scheduleSize: Int = 3
    public func set(scheduleSize: Int) {
        self.scheduleSize = scheduleSize
    }
    private var frameCountPerRead: AVAudioFrameCount = 24000
    public func set(frameCountPerRead: AVAudioFrameCount) {
        self.frameCountPerRead = frameCountPerRead
    }

    private var completionHandler: AVAudioNodeCompletionHandler? = nil
    public func scheduleRemoteFile(_ url: URL, completionHandler: AVAudioNodeCompletionHandler? = nil) {
        self.completionHandler = completionHandler
        audioFileStreamServices = AudioFileStreamService()
        self.downloader.request(url: url, completionHandler: { [weak self] (data: Data) in
            self?.onAudioData(data: data)
        })
    }
    
    private func onAudioData(data: Data) {
        audioFileStreamServices?.parseBytes(data: data, completeHandler:
                { [weak self] (audioFormat: AVAudioFormat, packets: [(data: Data, description: AudioStreamPacketDescription)]) in
                    self?.onPackets(audioFormat: audioFormat, packets: packets)
        })
    }

    var converter: CompressedBufferConverter? = nil
    private func onPackets(audioFormat: AVAudioFormat, packets: [(data: Data, description: AudioStreamPacketDescription)]) {
        converter = CompressedBufferConverter(srcFormat: audioFormat, dstFormat: internalFormat, packets: packets)
        for _ in 0..<scheduleSize {
            playScheduleBuffer()
        }
    }
    
    var bufferingCounter: Int = 0
    private func playScheduleBuffer() {
        if let ret = converter?.read(frames: frameCountPerRead), ret.frameLength > 0 {
            bufferingCounter += 1
            self.scheduleBuffer(ret, completionHandler: { [weak self] in
                self?.bufferingCounter -= 1
                self?.playScheduleBuffer()
            })
        } else {
            if bufferingCounter == 0 {
                completionHandler?()
            }
        }
    }
}
