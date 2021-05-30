//
//  ContentView.swift
//  
//
//  Created by fuziki on 2021/05/17.
//

import Combine
import ComposableArchitecture
import SwiftUI

public struct ContentView: View {
    let store: Store<ContentState, ContentAction>

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Button("Search") { viewStore.send(.search) }
                VStack {
                    ForEach(viewStore.fileList, id: \.self) { (file: String) in
                        Button("\(file)") {
                            viewStore.send(.play(file: file))
                        }
                    }
                }
            }
        }
    }
}

extension ContentView {
    public init() {
        let store = Store(
            initialState: ContentState(),
            reducer: contentReducer,
            environment: ContentEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                endpointClient: DefaultEndpointClient(),
                audioEngineService: DefaultAudioEngineService()
            )
        )
        self.init(store: store)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(
            initialState: ContentState(),
            reducer: contentReducer,
            environment: ContentEnvironment(
                mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
                endpointClient: DefaultEndpointClient(),
                audioEngineService: AudioEngineServiceMock()
            )
        ))
    }
}

