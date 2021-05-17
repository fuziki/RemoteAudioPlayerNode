//
//  RemoteAudioDownloader.swift
//  Example
//
//  Created by fuziki on 2019/12/22.
//  Copyright © 2019 fuziki.factory. All rights reserved.
//

import Foundation

public protocol RemoteAudioDownloader {
    func request(url: URL, completionHandler: @escaping (_ data: Data) -> Void)
}
 
internal class DefaultRemoteAudioDownloader: RemoteAudioDownloader {
    private var task: URLSessionDataTask?
    private var completionHandler: ((_ data: Data) -> Void)?
    public func request(url: URL, completionHandler: @escaping (Data) -> Void) {
        self.completionHandler = completionHandler
        let request = URLRequest(url: url)
        task = URLSession.shared.dataTask(with: request, completionHandler: { [weak self] (data: Data?, response: URLResponse?, error: Error?) in
            guard let self = self, let data = data else { return }
            self.completionHandler?(data)
        })
        task?.resume()
    }
}
