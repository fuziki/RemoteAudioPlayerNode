//
//  ContentView.swift
//  
//
//  Created by fuziki on 2021/05/17.
//

import SwiftUI

public struct ContentView: View {
    @ObservedObject var vm = ContentViewModel()
    
    public init() {
        
    }
    public var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            ForEach(vm.fileList, id: \.self) { (file: String) in
                Text(file)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

