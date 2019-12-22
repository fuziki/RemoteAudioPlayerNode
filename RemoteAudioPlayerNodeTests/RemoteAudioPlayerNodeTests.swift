//
//  RemoteAudioPlayerNodeTests.swift
//  RemoteAudioPlayerNodeTests
//
//  Created by fuziki on 2019/12/22.
//  Copyright © 2019 fuziki.factory. All rights reserved.
//

import XCTest
import AVFoundation
@testable import RemoteAudioPlayerNode

class RemoteAudioPlayerNodeTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    let downloader: RemoteAudioDownloader = DefaultRemoteAudioDownloader()
    func testDownload() {
        let expectation = XCTestExpectation(description: "\(#function)")
        let url = URL(string: "http://www.ne.jp/asahi/music/myuu/wave/fanfare.mp3")!
        downloader.request(url: url, completionHandler: { (data: Data) in
            XCTAssertEqual(data.count, 188034)
            expectation.fulfill()
        })
        self.wait(for: [expectation], timeout: 10)
    }
    
    let audioFileStreamServices = AudioFileStreamService()
    func testParse() {
        let expectation = XCTestExpectation(description: "\(#function)")
        let url = URL(string: "http://www.ne.jp/asahi/music/myuu/wave/fanfare.mp3")!
        downloader.request(url: url, completionHandler: { [weak self] (data: Data) in
            self?.audioFileStreamServices
                .parseBytes(data: data,
                            completeHandler: { (audioFormat: AVAudioFormat, packets: [(data: Data, description: AudioStreamPacketDescription)]) in
                                XCTAssertEqual(packets.count, 450)
                                expectation.fulfill()
            })
        })
        self.wait(for: [expectation], timeout: 10)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
