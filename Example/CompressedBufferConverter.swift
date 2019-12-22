//
//  CompressedBufferConverter.swift
//  Example
//
//  Created by fuziki on 2019/12/22.
//  Copyright © 2019 fuziki.factory. All rights reserved.
//

import Foundation
import AVFoundation

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
    
    public func seek(index: Int) {
        self.index = index
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
