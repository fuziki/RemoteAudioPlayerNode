//
//  AudioFileStreamService.swift
//  Example
//
//  Created by fuziki on 2019/12/21.
//  Copyright © 2019 fuziki.factory. All rights reserved.
//

import Foundation
import AVFoundation

public class AudioFileStreamService {
    private var streamID: AudioFileStreamID?

    private var audioFormat: AVAudioFormat?
    private var packets: [(data: Data, description: AudioStreamPacketDescription)]?
    
    public init() {
        let inClientData = unsafeBitCast(self, to: UnsafeMutableRawPointer.self)
        let error = AudioFileStreamOpen(inClientData,
                                        { (c , s, p, f) in AudioFileStreamService.propertyListenerProcedure(c , s, p, f) },
                                        { (c, b, p, d, pd) in AudioFileStreamService.packetsProcedure(c, b, p, d, pd) },
                                        kAudioFileMP3Type,
                                        &streamID)
        if error != noErr {
            print("error \(#function)")
        }
    }
    
    private var parseBytesCompleteHandler: ((_ audioFormat: AVAudioFormat, _ packets: [(data: Data, description: AudioStreamPacketDescription)]) -> Void)? = nil
    public func parseBytes(data: Data,
                           completeHandler: ((_ audioFormat: AVAudioFormat, _ packets: [(data: Data, description: AudioStreamPacketDescription)]) -> Void)? = nil) {
        self.parseBytesCompleteHandler = completeHandler
        guard let streamID = self.streamID else {
            return
        }
        let res: OSStatus = data.withUnsafeBytes({ (ptr: UnsafeRawBufferPointer) in
            return AudioFileStreamParseBytes(streamID, UInt32(ptr.count), ptr.baseAddress, [])
        })
        if res != noErr {
            print("error \(#function) \(res)")
        }
    }
    
    private var propertyListenerClojure: ((_ audioFormat: AVAudioFormat) -> Void)? = nil
    public func set(propertyListenerClojure: @escaping ((_ audioFormat: AVAudioFormat) -> Void)) {
        self.propertyListenerClojure = propertyListenerClojure
    }
    
    private var packetsClojure: ((_ packets: [(data: Data, description: AudioStreamPacketDescription)]) -> Void)? = nil
    public func set(packetsClojure: @escaping ((_ packets: [(data: Data, description: AudioStreamPacketDescription)]) -> Void)) {
        self.packetsClojure = packetsClojure
    }
    
    private func parsed(audioFormat: AVAudioFormat) {
        self.audioFormat = audioFormat
        self.propertyListenerClojure?(audioFormat)
    }
    
    private func parsed(packets: [(data: Data, description: AudioStreamPacketDescription)]) {
        self.packets = packets
        self.packetsClojure?(packets)
        guard let format = self.audioFormat else {
            return
        }
        self.parseBytesCompleteHandler?(format, packets)
    }
}

extension AudioFileStreamService {
//    public typealias AudioFileStream_PropertyListenerProc = @convention(c) (UnsafeMutableRawPointer, AudioFileStreamID, AudioFileStreamPropertyID, UnsafeMutablePointer<AudioFileStreamPropertyFlags>) -> Void
    static func propertyListenerProcedure(_ inClientData: UnsafeMutableRawPointer,
                                          _ inAudioFileStream: AudioFileStreamID,
                                          _ inPropertyID: AudioFileStreamPropertyID,
                                          _ ioFlags: UnsafeMutablePointer<AudioFileStreamPropertyFlags>) {
        let audioFileStreamService = Unmanaged<AudioFileStreamService>.fromOpaque(inClientData).takeUnretainedValue()
        switch inPropertyID {
        case kAudioFileStreamProperty_DataFormat:
            var description = AudioStreamBasicDescription()
            var propSize: UInt32 = 0
            let res1 = AudioFileStreamGetPropertyInfo(inAudioFileStream, inPropertyID, &propSize, nil)
            if res1 != noErr {
                print("failed AudioFileStreamGetPropertyInfo")
                return
            }
            let res2 = AudioFileStreamGetProperty(inAudioFileStream, inPropertyID, &propSize, &description)
            if res2 != noErr {
                print("failed AudioFileStreamGetProperty")
            }
            print("kAudioFileStreamProperty_DataFormat \(description)")
            if let format = AVAudioFormat(streamDescription: &description) {
                audioFileStreamService.parsed(audioFormat: format)
            }
        default:
            print("unknown propertyID \(inPropertyID)")
        }
    }
    
//    public typealias AudioFileStream_PacketsProc = @convention(c) (UnsafeMutableRawPointer, UInt32, UInt32, UnsafeRawPointer, UnsafeMutablePointer<AudioStreamPacketDescription>) -> Void
    static func packetsProcedure(_ inClientData: UnsafeMutableRawPointer,
                                 _ inNumberBytes: UInt32,
                                 _ inNumberPackets: UInt32,
                                 _ inInputData: UnsafeRawPointer,
                                 _ inPacketDescriptions: UnsafeMutablePointer<AudioStreamPacketDescription>) {
        let audioFileStreamService = Unmanaged<AudioFileStreamService>.fromOpaque(inClientData).takeUnretainedValue()
        var packets: [(data: Data, description: AudioStreamPacketDescription)] = []
        let packetDescriptionList = Array(UnsafeBufferPointer(start: inPacketDescriptions, count: Int(inNumberPackets)))
        for i in 0 ..< Int(inNumberPackets) {
            let packetDescription = packetDescriptionList[i]
            let startOffset = Int(packetDescription.mStartOffset)
            let byteSize = Int(packetDescription.mDataByteSize)
            let packetData = Data(bytes: inInputData.advanced(by: startOffset), count: byteSize)
            packets.append((data: packetData, description: packetDescription))
        }
        audioFileStreamService.parsed(packets: packets)
    }
}
