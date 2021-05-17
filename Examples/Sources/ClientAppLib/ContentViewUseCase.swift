//
//  ContentViewUseCase.swift
//  
//
//  Created by fuziki on 2021/05/17.
//

import Combine

class ContentViewUseCase {
    private let fileList = CurrentValueSubject<[String], Never>([])
    public var fileListPublisher: AnyPublisher<[String], Never> {
        return fileList.eraseToAnyPublisher()
    }
    private let fileListApi = FileListApi(expect: 5)
    
    private var cancellables: Set<AnyCancellable> = []
    func fetch() {
        fileListApi
            .request()
            .catch { _ in Empty() }
            .sink { [weak self] (res: FileListApi.Response) in
                self?.fileList.send(res.fileList)
            }
            .store(in: &cancellables)
    }
}
