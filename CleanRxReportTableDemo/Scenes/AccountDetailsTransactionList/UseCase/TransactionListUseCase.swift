//  Copyright © 2020 Lyle Resnick. All rights reserved.

import Foundation
import RxSwift
import RxEnumKit

class TransactionListUseCase {
    var entityGateway: EntityGateway
    
    required init(entityGateway: EntityGateway) {
        self.entityGateway = entityGateway
    }
    
    func transform(input: Observable<TransactionListUseCaseInput>) -> Observable<TransactionListUseCaseOutput> {
        
        let transformer = TransactionListUseCaseTransformer(transactionManager: entityGateway.transactionManager)

        return .merge(
            transformer.refreshTwoSourceTransform(input: input),
            transformer.refreshOneSourceTransform(input: input)
        )
    }
}


struct TransactionListUseCaseTransformer {
    let transactionManager: TransactionManager

    init(transactionManager: TransactionManager) {
        self.transactionManager = transactionManager
    }
}
