//
//  ContentState.swift
//  
//
//  Created by fuziki on 2021/05/22.
//

import Combine
import ComposableArchitecture
import EndpointInterface

struct ContentState: Equatable {
    var fileList: [String] = []
}

enum ContentAction: Equatable {
    case search
    case searched(fileList: [String])
    case play(file: String)
}

struct ContentEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let endpointClient: EndpointClient
    let audioEngineService: AudioEngineService
}

let contentReducer = Reducer<ContentState, ContentAction, ContentEnvironment> {
    (state: inout ContentState, action: ContentAction, environment: ContentEnvironment) -> Effect<ContentAction, Never> in
    switch action {
    case .search:
        return environment.endpointClient
            .request(interface: FileListEndpoint.self, body: .init(expect: 5))
            .receive(on: environment.mainQueue)
            .catch { _ in Empty() }
            .map { $0.fileList }
            .eraseToEffect()
            .map(ContentAction.searched)
    case .searched(let fileList):
        state.fileList = fileList
        return .none
    case .play(let file):
        environment.audioEngineService.play(file: file)
        return .none
    }
}
