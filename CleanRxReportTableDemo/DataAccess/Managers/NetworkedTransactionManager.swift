//  Copyright © 2020 Lyle Resnick. All rights reserved.

import Foundation
import RxSwift
import RxCocoa

class NetworkedTransactionManager: TransactionManager {
        
    private let defaultSession = URLSession(configuration: .default)
    private let baseURLString = "https://report-demo-backend.herokuapp.com/api"

    private let formatter = DateFormatter.dateFormatter( format: "yyyy-MM-dd'T'HH:mm:ss'Z'")
    private lazy var decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }()
    
    func fetchAuthorizedTransactions() -> Single<[Transaction]> {
        return fetch(path: "transactions/authorized")
    }

    func fetchPostedTransactions() -> Single<[Transaction]> {
        return fetch(path: "transactions/posted")
    }

    func fetchAllTransactions() -> Single<[Transaction]> {
        return fetch(path: "transactions/all")
    }
    
    private func fetch(path: String) -> Single<[Transaction]> {
        
        let url = URL(string: baseURLString + "/" + path)!
        let request = URLRequest(url: url)
        
        let result = defaultSession.rx.data(request: request)
            .map { data -> [Transaction] in
                do {
                    let networkedTransactionList = try self.decoder.decode([NetworkedTransaction].self, from: data)
                    return networkedTransactionList
                        .compactMap(Transaction.init(networkedTransaction:))
                }
                catch {
                    throw TransactionError.failure(code: 0, description: error.localizedDescription)
                }
            }
            .catchError { error in
                switch error {
                case let RxCocoaURLError.httpRequestFailed(request, _):
                    if request.statusCode == 404 {
                        throw TransactionError.notFound
                    }
                    throw TransactionError.failure(code: request.statusCode, description: request.description)
                default:
                    throw TransactionError.failure(code: 0, description: error.localizedDescription)
                }
        }

        return result.asSingle()
    }
}
