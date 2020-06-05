//  Copyright © 2020 Lyle Resnick. All rights reserved.

import RxSwift

enum  TransactionError: Error {
    case notFound
    case failure(code: Int, description: String)
}

protocol TransactionManager: class {
    
    func fetchAuthorizedTransactions() -> Single<[Transaction]>
    func fetchPostedTransactions() -> Single<[Transaction]>
    func fetchAllTransactions() -> Single<[Transaction]>
}

